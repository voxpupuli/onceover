require 'pry'

class OnceoverFormatter
  RSpec::Core::Formatters.register self, :example_group_started,
    :example_passed, :example_failed, :example_pending, :dump_failures, :dump_summary

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
        padding = longest_group - role.length
        # Create padding
        padding.times { @output << ' ' }

        # Save the role name
        @previous_role = role
      end
    else
      # If not then this will be a test for that role
      @output << '🎁 '
    end
  end

  def example_passed notification
    @output << "\b\b\b"
    @output << "🍺 "
  end

  def example_failed notification
    @output << "\b\b\b"
    @output << "💩 "
  end

  def example_pending notification
    @output << "\b\b\b"
    @output << "🤷 "
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

  # def dump_summary notification
  #   binding.pry
  # end

  private

  # Below are defined the styles for the output
  def class_name(text)
    RSpec::Core::Formatters::ConsoleCodes.wrap(text, :bold)
  end

  def red(text)
    RSpec::Core::Formatters::ConsoleCodes.wrap(text, :red)
  end

  def longest_group
    RSpec.configuration.world.example_groups.max { |a,b| a.description.length <=> b.description.length}.description.length
  end

end