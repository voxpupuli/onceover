# handle local deployments (run r10k in .onceover dir)
class Onceover
  class Deploy
    def deploy_local(repo = Onceover::Controlrepo.new, opts = {})
      require 'onceover/controlrepo'
      require 'pathname'

      logger.debug 'Deploying locally (R10K)...'

      skip_r10k = opts[:skip_r10k] || false
      force     = opts[:force] || false

      if repo.tempdir == nil
        repo.tempdir = Dir.mktmpdir('r10k')
      else
        logger.debug "Creating #{repo.tempdir}"
        FileUtils.mkdir_p(repo.tempdir)
      end

      # We need to do the copy to a tempdir then move the tempdir to the
      # destination, just in case we get a recursive copy
      # TODO: Improve this to save I/O

      # We might need to exclude some files
      #
      # if we are using bundler to install gems below the controlrepo
      # we don't want two copies so exclude those
      #
      # If there are more situations like this we can add them to this array as
      # full paths
      excluded_dirs = []
      excluded_dirs << Pathname.new("#{repo.root}/.onceover")
      excluded_dirs << Pathname.new(ENV['GEM_HOME']) if ENV['GEM_HOME']

      #
      # A Local modules directory likely means that the user installed r10k folders into their local control repo
      # This conflicts with the step where onceover installs r10k after copying the control repo to the temporary
      # .onceover directory.  The following skips copying the modules folder, to not later cause an error.
      #
      if File.directory?("#{repo.root}/modules")
        logger.warn "Found modules directory in your controlrepo, skipping the copy of this directory.  If you installed modules locally using r10k, this warning is normal, if you have created modules in a local modules directory, onceover does not support testing these files, please rename this directory to conform with Puppet best practices, as this folder will conflict with Puppet's native installation of modules."
      end
      excluded_dirs << Pathname.new("#{repo.root}/modules")

      controlrepo_files = get_children_recursive(Pathname.new(repo.root))

      # Exclude the files that should be skipped
      controlrepo_files.delete_if do |path|
        parents = [path]
        path.ascend do |parent|
          parents << parent
        end
        parents.any? { |x| excluded_dirs.include?(x) }
      end

      folders_to_copy = controlrepo_files.select { |x| x.directory? }
      files_to_copy   = controlrepo_files.select { |x| x.file? }

      logger.debug "Creating temp dir as a staging directory for copying the controlrepo to #{repo.tempdir}"
      temp_controlrepo = Dir.mktmpdir('controlrepo')

      logger.debug "Creating directories under #{temp_controlrepo}"
      FileUtils.mkdir_p(folders_to_copy.map { |folder| "#{temp_controlrepo}/#{(folder.relative_path_from(Pathname(repo.root))).to_s}"})

      logger.debug "Copying files to #{temp_controlrepo}"
      files_to_copy.each do |file|
        FileUtils.cp(file,"#{temp_controlrepo}/#{(file.relative_path_from(Pathname(repo.root))).to_s}")
      end

      logger.debug "Writing manifest of copied controlrepo files"
      require 'json'
      # Create a manifest of all files that were in the original repo
      manifest = controlrepo_files.map do |file|
        # Make sure the paths are relative so they remain relevant when used later
        file.relative_path_from(Pathname(repo.root)).to_s
      end
      # Write all but the first as this is the root and we don't care about that
      File.write("#{temp_controlrepo}/.onceover_manifest.json",manifest[1..-1].to_json)

      # When using puppetfile vs deploy with r10k, we want to respect the :control_branch
      # located in the Puppetfile. To accomplish that, we use git and find the current
      # branch name, then replace strings within the staged puppetfile, prior to copying.

      logger.debug "Checking current working branch"
      git_branch = `git rev-parse --abbrev-ref HEAD`.chomp

      logger.debug "found #{git_branch} as current working branch"
      puppetfile_contents = File.read("#{temp_controlrepo}/Puppetfile")

      logger.debug "replacing :control_branch mentions in the Puppetfile with #{git_branch}"
      new_puppetfile_contents = puppetfile_contents.gsub(/:control_branch/, "'#{git_branch}'")
      File.write("#{temp_controlrepo}/Puppetfile", new_puppetfile_contents)

      # Remove all files written by the laste onceover run, but not the ones
      # added by r10k, because that's what we are trying to cache but we don't
      # know what they are
      old_manifest_path = "#{repo.tempdir}/#{repo.environmentpath}/production/.onceover_manifest.json"
      if File.exist? old_manifest_path
        logger.debug "Found manifest from previous run, parsing..."
        old_manifest = JSON.parse(File.read(old_manifest_path))
        logger.debug "Removing #{old_manifest.count} files"
        old_manifest.reverse.each do |file|
          FileUtils.rm_f(File.join("#{repo.tempdir}/#{repo.environmentpath}/production/",file))
        end
      end
      FileUtils.mkdir_p("#{repo.tempdir}/#{repo.environmentpath}")

      logger.debug "Copying #{temp_controlrepo} to #{repo.tempdir}/#{repo.environmentpath}/production"
      FileUtils.cp_r("#{temp_controlrepo}/.", "#{repo.tempdir}/#{repo.environmentpath}/production")
      FileUtils.rm_rf(temp_controlrepo)

      # Pull the trigger! If it's not already been pulled
      if repo.tempdir and not skip_r10k
        if File.directory?(repo.tempdir)
          # TODO: Change this to call out to r10k directly to do this
          # Probably something like:
          # R10K::Settings.global_settings.evaluate(with_overrides)
          # R10K::Action::Deploy::Environment
          prod_dir = "#{repo.tempdir}/#{repo.environmentpath}/production"
          Dir.chdir(prod_dir) do
            install_cmd = []
            install_cmd << "r10k puppetfile install --verbose --color --puppetfile #{repo.puppetfile}"
            install_cmd << "--force" if force
            install_cmd = install_cmd.join(' ')
            logger.debug "Running #{install_cmd} from #{prod_dir}"
            system(install_cmd)
            raise 'r10k could not install all required modules' unless $?.success?
          end
        else
          raise "#{repo.tempdir} is not a directory"
        end
      end

      # Return repo.tempdir for use
      repo.tempdir
    end

    private

    def get_children_recursive(pathname)
      results = []
      results << pathname
      pathname.each_child do |child|
        results << child
        if child.directory?
          results << get_children_recursive(child)
        end
      end
      results.flatten
    end
  end
end