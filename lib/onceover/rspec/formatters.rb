require 'pry'

class OnceoverFormatter
  RSpec::Core::Formatters.register self, :example_group_started,
    :example_passed, :example_failed, :example_pending, :dump_failures#, :dump_summary

  COMPILATION_ERROR        = %r{error during compilation: (?<error>.*)}
  COMPILATION_ERROR_FORMAT = %r{(?<error>.*?)\s(at )?(\(file: (?<file>.*?), line: (?<line>\d+)(, column: (?<column>\d+))?\))(; )?}

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
    # Group by role
    grouped = notification.failed_examples.group_by { |e| e.metadata[:example_group][:parent_example_group][:description]}

    # Further group by error
    grouped.each do |role, failures|
      grouped[role] = failures.uniq { |f| f.metadata[:execution_result].exception.to_s }
    end

    grouped.each do |role, failures|
      @output << "\n\n\n"
      @output << "#{role}: #{red('failed')}\n"
      @output << "  errors:\n"
      failures.each { |f| @output << "    #{red(f.metadata[:execution_result].exception.to_s)}\n"}
      @output << "\n"
    end
  end

  def parse_errors(raw_error)
    # Check if the error is a compilation error
    match = COMPILATION_ERROR.match(raw_error)
    if match
      compilation_error = match.named_captures['error']
      # Check if we car parse it
      if COMPILATION_ERROR_FORMAT.match?(compilation_error)
        scanned_errors = match.named_captures['error'].scan(COMPILATION_ERROR_FORMAT)
        require 'pry'
        binding.pry
      else
        nil
      end
    else
      # If the error cannot be parse return nil
      nil
    end
  end

  private

  # Below are defined the styles for the output
  def class_name(text)
    RSpec::Core::Formatters::ConsoleCodes.wrap(text, :bold)
  end

  def red(text)
    RSpec::Core::Formatters::ConsoleCodes.wrap(text, :red)
  end

  def yellow(text)
    RSpec::Core::Formatters::ConsoleCodes.wrap(text, :yellow)
  end

  def green(text)
    RSpec::Core::Formatters::ConsoleCodes.wrap(text, :green)
  end

  def longest_group
    RSpec.configuration.world.example_groups.max { |a,b| a.description.length <=> b.description.length}.description.length
  end

end

# class OnceoverFormatterParallel < OnceoverFormatter
#   require 'yaml'

#   def example_group_started notification
#     # Do nothing
#   end

#   def example_passed notification
#     @output << green('P')
#   end

#   def example_failed notification
#     @output << red('F')
#   end

#   def example_pending notification
#     @output << yellow('?')
#   end

#   def dump_failures
#     # TODO: This should write to a file and then get picked up and formatted by onceover itself
#     # might need to use a module for the formatting
#     require 'pry'
#     binding.pry
#     RSpec.configuration.onceover_tempdir
#   end

# end

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