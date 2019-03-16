require 'pathname'

class OnceoverFormatter
  RSpec::Core::Formatters.register self, :example_group_started,
    :example_passed, :example_failed, :example_pending, :dump_failures#, :dump_summary

  COMPILATION_ERROR      = %r{error during compilation: (?<error>.*)}
  ERROR_WITH_LOCATION    = %r{(?<error>.*?)\s(at )?(\((file: (?<file>.*?), )?line: (?<line>\d+)(, column: (?<column>\d+))?\))(; )?}
  ERROR_WITHOUT_LOCATION = %r{(?<error>.*?)\son node}

  def initialize output
    @output        = output
    @previous_role = nil
  end

  def example_group_started notification
    if notification.group.parent_groups == [notification.group]
      # If this is the highest level group (The role)
      role = notification.group.description
      if role != @previous_role
        @output << "\n"
        @output << class_name("#{notification.group.description}:")

        # Calculate the padding required
        padding = (longest_group - role.length) + 1
        # Create padding
        padding.times { @output << ' ' }

        # Save the role name
        @previous_role = role
      end
    else
      # If not then this will be a test for that role
      @output << '? '
    end
  end

  def example_passed notification
    @output << "\b\b"
    @output << "#{green('P')} "
  end

  def example_failed notification
    @output << "\b\b"
    @output << "#{red('F')} "
  end

  def example_pending notification
    @output << "\b\b"
    @output << "#{yellow('?')} "
  end

  def dump_failures notification
    require 'onceover/controlrepo'

    # Group by role
    grouped = notification.failed_examples.group_by { |e| e.metadata[:example_group][:parent_example_group][:description]}

    # Further group by error
    grouped.each do |role, failures|
      grouped[role] = failures.uniq { |f| f.metadata[:execution_result].exception.to_s }
    end

    # Put some spacing before the results
    @output << "\n\n\n"

    grouped.each do |role, failures|
      role = {
        name: role,
        errors: failures.map { |f| parse_errors(f.metadata[:execution_result].exception.to_s)}.flatten,
      }

      @output << Onceover::Controlrepo.evaluate_template('error_summary.yaml.erb', binding)
    end
  end

  def parse_errors(raw_error)
    # Check if the error is a compilation error
    match = COMPILATION_ERROR.match(raw_error)
    if match
      compilation_error = match['error']
      # Check if we car parse it
      if ERROR_WITH_LOCATION.match(compilation_error)
        scanned_errors = match['error'].scan(ERROR_WITH_LOCATION)

        # Delete any matches where there was no error text
        scanned_errors.delete_if { |e| e.first.empty? }

        scanned_errors.map do |error_matches|
          {
            text:   error_matches[0],
            file:   calculate_relative_source(error_matches[1]),
            line:   error_matches[2],
            column: error_matches[3],
          }
        end
      elsif ERROR_WITHOUT_LOCATION.match(compilation_error)
        scanned_errors = match['error'].scan(ERROR_WITHOUT_LOCATION)

        # Delete any matches where there was no error text
        scanned_errors.delete_if { |e| e.first.empty? }

        scanned_errors.map do |error_matches|
          {
            text: error_matches[0],
          }
        end
      else
        [{
          text: raw_error,
        }]
      end
    else
      [{
        text: raw_error,
      }]
    end
  end

  # This method calculates where the original source file is relative to the
  # user's current location. This is more compliacted than it sounds because
  # if we are running from the root of the controlrepo and we have an error in:
  #
  # /Users/dylan/git/puppet_controlrepo/.onceover/etc/puppetlabs/code/environments/production/site/role/manifests/lb.pp
  #
  # We need that to end up pointing at the original source file not the cached
  # one i.e.
  #
  # site/role/manifests/lb.pp
  #
  def calculate_relative_source(file)
    return nil if file.nil?

    file            = Pathname.new(file)
    tempdir         = Pathname.new(RSpec.configuration.onceover_tempdir)
    root            = Pathname.new(RSpec.configuration.onceover_root)
    environmentpath = Pathname.new(RSpec.configuration.onceover_environmentpath)

    # Calculate the full relative path
    file.relative_path_from(tempdir + environmentpath + "production").to_s
  end

  private

  # Below are defined the styles for the output
  def class_name(text)
    RSpec::Core::Formatters::ConsoleCodes.wrap(text, :bold)
  end

  def black(text)
    RSpec::Core::Formatters::ConsoleCodes.wrap(text, :black)
  end

  def red(text)
    RSpec::Core::Formatters::ConsoleCodes.wrap(text, :red)
  end

  def green(text)
    RSpec::Core::Formatters::ConsoleCodes.wrap(text, :green)
  end

  def yellow(text)
    RSpec::Core::Formatters::ConsoleCodes.wrap(text, :yellow)
  end

  def blue(text)
    RSpec::Core::Formatters::ConsoleCodes.wrap(text, :blue)
  end

  def magenta(text)
    RSpec::Core::Formatters::ConsoleCodes.wrap(text, :magenta)
  end

  def cyan(text)
    RSpec::Core::Formatters::ConsoleCodes.wrap(text, :cyan)
  end

  def white(text)
    RSpec::Core::Formatters::ConsoleCodes.wrap(text, :white)
  end

  def bold(text)
    RSpec::Core::Formatters::ConsoleCodes.wrap(text, :bold)
  end

  def longest_group
    RSpec.configuration.world.example_groups.max { |a,b| a.description.length <=> b.description.length}.description.length
  end

end

class OnceoverFormatterParallel < OnceoverFormatter
  require 'yaml'

  def example_group_started notification
    # Do nothing
  end

  def example_passed notification
    @output << green('P')
  end

  def example_failed notification
    @output << red('F')
  end

  def example_pending notification
    @output << yellow('?')
  end

  def dump_failures
    # Create a random string
    require 'securerandom'
    random_string = SecureRandom.hex

    # Ensure that the folder exists
    FileUtils.mkdir_p "#{RSpec.configuration.onceover_tempdir}/parallel"

    # Dump the notification to a unique file
    File.open("#{RSpec.configuration.onceover_tempdir}/parallel/results-#{random_string}", "w") do |file|
      file.write(pets.to_yaml)
    end
  end

  def self.read_results(directory)
    # Read all yaml files
    require 'pry'
    binding.pry
    # Delete them from the disk

    # Merge data
  end
end

class FailureCollector
  RSpec::Core::Formatters.register self, :dump_failures

  def initialize(output)
    FileUtils.touch(File.expand_path("#{RSpec.configuration.onceover_tempdir}/failures.out"))
  end

  def dump_failures(failures)
    open(File.expand_path("#{RSpec.configuration.onceover_tempdir}/failures.out"), 'a') { |f|
      failures.failed_examples.each do |fe|
        f.puts
        f.puts "#{fe.metadata[:description]}"
        f.puts "#{fe.metadata[:execution_result].exception.to_s}"
        f.puts "#{fe.metadata[:file_path]}:#{fe.metadata[:line_number]}"
        f.puts "------------------------------------------------------"
      end
    }
  end
end