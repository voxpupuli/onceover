require 'onceover/class'
require 'onceover/node'
require 'onceover/group'
require 'onceover/test'
require 'onceover/logger'
require 'onceover/controlrepo'
require 'git'
include Onceover::Logger

class Onceover
  class TestConfig
    require 'yaml'

    attr_accessor :classes
    attr_accessor :nodes
    attr_accessor :node_groups
    attr_accessor :class_groups
    attr_accessor :spec_tests
    attr_accessor :acceptance_tests
    attr_accessor :environment
    attr_accessor :opts
    attr_accessor :filter_tags
    attr_accessor :filter_classes
    attr_accessor :filter_nodes
    attr_accessor :mock_functions
    attr_accessor :before_conditions
    attr_accessor :after_conditions
    attr_accessor :skip_r10k
    attr_accessor :force
    attr_accessor :strict_variables

    def initialize(file, opts = {})
      begin
        config = YAML.safe_load(File.read(file))
      rescue Errno::ENOENT
        raise "Could not find #{file}"
      rescue Psych::SyntaxError
        raise "Could not parse #{file}, check that it is valid YAML and that the encoding is correct"
      end

      @classes           = []
      @nodes             = []
      @node_groups       = []
      @class_groups      = []
      @spec_tests        = []
      @acceptance_tests  = []
      @opts              = opts
      @mock_functions    = config['functions']
      @before_conditions = config['before']
      @after_conditions  = config['after']
      @strict_variables  = opts[:strict_variables] ? 'yes' : 'no'

      # Initialise all of the classes and nodes
      config['classes'].each { |clarse| Onceover::Class.new(clarse) } unless config['classes'] == nil
      @classes = Onceover::Class.all

      config['nodes'].each { |node| Onceover::Node.new(node) } unless config['nodes'] == nil
      @nodes = Onceover::Node.all

      # Add the 'all_classes' and 'all_nodes' default groups
      @node_groups  << Onceover::Group.new('all_nodes', @nodes)
      @class_groups << Onceover::Group.new('all_classes', @classes)

      # Initialise all of the groups
      config['node_groups'].each { |name, members| @node_groups << Onceover::Group.new(name, members) } unless config['node_groups'] == nil
      config['class_groups'].each { |name, members| @class_groups << Onceover::Group.new(name, members) } unless config['class_groups'] == nil

      @filter_tags    = opts[:tags]      ? [opts[:tags].split(',')].flatten : nil
      @filter_classes = opts[:classes]   ? [opts[:classes].split(',')].flatten.map {|x| Onceover::Class.find(x)} : nil
      @filter_nodes   = opts[:nodes]     ? [opts[:nodes].split(',')].flatten.map {|x| Onceover::Node.find(x)} : nil
      @skip_r10k      = opts[:skip_r10k] ? true : false
      @force          = opts[:force] || false

      # Loop over all of the items in the test matrix and add those as test
      # objects to the list of tests
      config['test_matrix'].each do |test_hash|
        test_hash.each do |machines, settings|
          if settings['tests'] == 'spec'
            @spec_tests << Onceover::Test.new(machines, settings['classes'], settings)
          elsif settings['tests'] == 'acceptance'
            @acceptance_tests << Onceover::Test.new(machines, settings['classes'], settings)
          elsif settings['tests'] == 'all_tests'
            tst = Onceover::Test.new(machines,settings['classes'],settings)
            @spec_tests << tst
            @acceptance_tests << tst
          end
        end
      end
    end

    def to_s
      require 'colored'

      <<-END.gsub(/^\s{4}/,'')
      #{'classes'.green}      #{@classes.map{|c|c.name}}
      #{'nodes'.green}        #{@nodes.map{|n|n.name}}
      #{'class_groups'.green} #{@class_groups}
      #{'node_groups'.green}  #{@node_groups.map{|g|g.name}}
      END
    end

    def self.find_list(thing)
      # Takes a string and finds an object or list of objects to match, will
      # take nodes, classes or groups

      # We want to supress warnings for this bit
      old_level = logger.level
      logger.level = :error
      if Onceover::Group.find(thing)
        logger.level = old_level
        return Onceover::Group.find(thing).members
      elsif Onceover::Class.find(thing)
        logger.level = old_level
        return [Onceover::Class.find(thing)]
      elsif Onceover::Node.find(thing)
        logger.level = old_level
        return [Onceover::Node.find(thing)]
      else
        logger.level = old_level
        raise "Could not find #{thing} in list of classes, nodes or groups"
      end
    end

    def self.subtractive_to_list(subtractive_hash)
      # Take a hash that looks like this:
      # { 'include' => 'somegroup'
      #   'exclude' => 'other'}
      # and return a list of classes/nodes
      include_list = Onceover::TestConfig.find_list(subtractive_hash['include']).flatten
      exclude_list = Onceover::TestConfig.find_list(subtractive_hash['exclude']).flatten
      include_list - exclude_list
    end

    def verify_spec_test(controlrepo, test)
      test.nodes.each do |node|
        unless controlrepo.facts_files.any? { |file| file =~ /\/#{node.name}\.json/ }
          raise "Could not find factset for node: #{node.name}"
        end
      end
    end

    def verify_acceptance_test(controlrepo, test)
      warn "[DEPRECATION] #{__method__} is deprecated due to the removal of Beaker"

      require 'yaml'
      nodeset = YAML.load_file(controlrepo.nodeset_file)
      test.nodes.each do |node|
        unless nodeset['HOSTS'].has_key?(node.name)
          raise "Could not find nodeset for node: #{node.name}"
        end
      end
    end

    def pre_condition
      # Read all the pre_conditions and return the string
      spec_dir = Onceover::Controlrepo.new(@opts).spec_dir
      puppetcode = []
      Dir["#{spec_dir}/pre_conditions/*.pp"].each do |condition_file|
        logger.debug "Reading pre_conditions from #{condition_file}"
        puppetcode << File.read(condition_file)
      end
      return nil if puppetcode.count.zero?
      puppetcode.join("\n")
    end

    def deploy_local(repo = Onceover::Controlrepo.new, opts = {})
      require 'onceover/controlrepo'
      require 'pathname'

      skip_r10k = opts[:skip_r10k] || false

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
            install_cmd << "--force" if @force
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

    def write_spec_test(location, test)
      # Use an ERB template to write a spec test
      File.write("#{location}/#{test.to_s}_spec.rb",
        Onceover::Controlrepo.evaluate_template('test_spec.rb.erb', binding))
    end

    def write_acceptance_tests(location, tests)
      warn "[DEPRECATION] #{__method__} is deprecated due to the removal of Beaker"

      File.write("#{location}/acceptance_spec.rb",
        Onceover::Controlrepo.evaluate_template('acceptance_test_spec.rb.erb', binding))
    end

    def write_spec_helper_acceptance(location, repo)
      File.write("#{location}/spec_helper_acceptance.rb",
        Onceover::Controlrepo.evaluate_template('spec_helper_acceptance.rb.erb', binding))
    end

    def write_rakefile(location, pattern)
      File.write("#{location}/Rakefile",
        Onceover::Controlrepo.evaluate_template('testconfig_Rakefile.erb', binding))
    end

    def write_spec_helper(location, repo)
      environmentpath = "#{repo.tempdir}/#{repo.environmentpath}"
      modulepath = repo.config['modulepath']
      modulepath.delete("$basemodulepath")
      modulepath.map! do |path|
        "#{environmentpath}/production/#{path}"
      end

      # We need to select the right delimiter based on OS
      require 'facter'
      if Facter[:kernel].value == 'windows'
        modulepath = modulepath.join(";")
      else
        modulepath = modulepath.join(':')
      end

      repo.temp_modulepath = modulepath

      # Use an ERB template to write a spec test
      File.write("#{location}/spec_helper.rb",
        Onceover::Controlrepo.evaluate_template('spec_helper.rb.erb', binding))
    end

    def create_fixtures_symlinks(repo)
      logger.debug "Creating fixtures symlinks"
      FileUtils.rm_rf("#{repo.tempdir}/spec/fixtures/modules")
      FileUtils.mkdir_p("#{repo.tempdir}/spec/fixtures/modules")
      repo.temp_modulepath.split(':').each do |path|
        Dir["#{path}/*"].each do |mod|
          modulename = File.basename(mod)
          link = "#{repo.tempdir}/spec/fixtures/modules/#{modulename}"
          logger.debug "Symlinking #{mod} to #{link}"
          unless File.symlink?(link)
            # Ruby only sets File::ALT_SEPARATOR on Windows and Rubys standard library
            # uses this to check for Windows
            if !!File::ALT_SEPARATOR
              mod = File.join(File.dirname(link), mod) unless Pathname.new(mod).absolute?
              if Dir.respond_to?(:create_junction)
                Dir.create_junction(link, mod)
              else
                system("call mklink /J \"#{link.gsub('/', '\\')}\" \"#{mod.gsub('/', '\\')}\"")
              end
            else
              FileUtils.ln_s(mod, link)
            end
          end
        end
      end
    end

    def run_filters(tests)
      # All of this needs to be applied AFTER deduplication but BEFORE writing
      filters = {
        'tags'    => @filter_tags,
        'classes' => @filter_classes,
        'nodes'   => @filter_nodes
      }
      filters.each do |method, filter_list|
        if filter_list
          # Remove tests that do not have matching tags
          tests.keep_if do |test|
            filter_list.any? do |filter|
              if test.send(method)
                test.send(method).include?(filter)
              else
                false
              end
            end
          end
        end
      end
      tests
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
