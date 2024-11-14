# handle local deployments (run r10k in .onceover dir)
class Onceover
  class Deploy
    def deploy_local(repo = Onceover::Controlrepo.new, opts = {})
      require 'onceover/controlrepo'
      require 'pathname'
      require 'fileutils'
      require 'multi_json'

      logger.debug 'Deploying locally (R10K)...'

      # Only default to running r10k if there is a Puppetfile
      skip_r10k_default = !(File.file?(repo.puppetfile))
      skip_r10k = opts[:skip_r10k] || skip_r10k_default
      force     = opts[:force] || false

      if repo.tempdir == nil
        repo.tempdir = Dir.mktmpdir('r10k')
      else
        logger.debug "Creating #{repo.tempdir}"
        FileUtils.mkdir_p(repo.tempdir)
      end

      # Overall plan: Copy everything in control repo to a tempdir then move the tempdir to the
      # destination, just in case we get a recursive copy

      # We need to exclude some files:
      # * our own cache
      # * stuff from git
      # * stale puppet modules
      # * random ruby gems (bundler/rvm?)
      # * ...etc
      excluded_dirs = [
        File.join(repo.root, ".onceover"),
        File.join(repo.root, ".git"),
        File.join(repo.root, ".modules"),
        File.join(repo.root, "vendor"),
      ]
      excluded_dirs << ENV['GEM_HOME'] if ENV['GEM_HOME']

      # A Local modules directory likely means that the user installed r10k folders into their local control repo
      # This conflicts with the step where onceover installs r10k after copying the control repo to the temporary
      # .onceover directory.  The following skips copying the modules folder, to not later cause an error.
      if File.directory?("modules")
        logger.warn "Found modules directory in your controlrepo, skipping the copy of this directory.  If you installed modules locally using r10k, this warning is normal, if you have created modules in a local modules directory, onceover does not support testing these files, please rename this directory to conform with Puppet best practices, as this folder will conflict with Puppet's native installation of modules."
      end

      logger.debug "Creating temp dir as a staging directory for copying the controlrepo to #{repo.tempdir}"
      temp_controlrepo = Dir.mktmpdir('controlrepo')

      # onceover stores a big list of all the relative paths it places within its cache directory
      onceover_manifest = []

      Find.find repo.root do |source|
        # work out a relative path to this source, eg:
        # /home/geoff/control-repo/foo/bar -> foo/bar
        relative_source = Pathname.new(source).relative_path_from(Pathname.new(repo.root)).to_s

        target = File.join(temp_controlrepo, relative_source)

        # ignore the path "." which represents the root of our control repo
        if relative_source != "."
          # add to list of files copied to cache by onceover
          onceover_manifest << relative_source

          if File.symlink?(source)
            # Handle symlinks
            link_target = File.readlink(source) # Get the target of the symlink
            FileUtils.ln_s link_target, target, force: true # Create symlink at target
          elsif File.directory? source
            Find.prune if excluded_dirs.include? source
            FileUtils.mkdir target
          else
            FileUtils.copy source, target
          end
        end
      end
      logger.debug "Writing manifest of copied controlrepo files"
      File.write("#{temp_controlrepo}/.onceover_manifest.json", onceover_manifest.to_json)

      # When using puppetfile vs deploy with r10k, we want to respect the :control_branch
      # located in the Puppetfile. To accomplish that, we use git and find the current
      # branch name, then replace strings within the staged puppetfile, prior to copying.
      logger.debug "Checking current working branch"
      git_branch = `git rev-parse --abbrev-ref HEAD`.chomp

      logger.debug "found #{git_branch} as current working branch"
      # Only try to modify Puppetfile if it exists
      unless skip_r10k
        FileUtils.copy repo.puppetfile, "#{temp_controlrepo}/Puppetfile"
        puppetfile_contents = File.read("#{temp_controlrepo}/Puppetfile")

        # Avoid touching thing if we don't need to
        if /:control_branch/.match(puppetfile_contents)
          logger.debug "replacing :control_branch mentions in the Puppetfile with #{git_branch}"
          new_puppetfile_contents = puppetfile_contents.gsub(":control_branch", "'#{git_branch}'")
          File.write("#{temp_controlrepo}/Puppetfile", new_puppetfile_contents)  
        end
      end

      # Remove all files written by the last onceover run, but not the ones
      # added by r10k, because that's what we are trying to cache but we don't
      # know what they are
      old_manifest_path = "#{repo.tempdir}/#{repo.environmentpath}/production/.onceover_manifest.json"
      if File.exist? old_manifest_path
        logger.debug "Found manifest from previous run, parsing..."
        old_manifest = MultiJson.load(File.read(old_manifest_path))
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
            install_cmd << 'r10k puppetfile install --color'
            install_cmd << "--force" if force
            install_cmd << "--config #{repo.r10k_config_file}" if repo.r10k_config_file
            install_cmd << (logger.level > 0 ? "--verbose" : "--verbose debug") # Enable debugging if we're debugging
            install_cmd << "--trace" if opts[:trace]
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
  end
end
