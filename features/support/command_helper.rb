require "open3"

class Command_Helper

  attr_reader(:output, :result)

  attr_writer(:command, :params, :controlrepo)

  def initialize
    @executable = ENV["BUNDLE_GEMFILE"] ? "bundle exec onceover" : "onceover"
  end

  def run
    @output, @result = Open3.capture2e generate_command
  end

  def success?
    return @result.success?
  end

  def generate_command
    controlrepo_param = @controlrepo ? "--path #{@controlrepo.root_folder}" : ''
    return "#{@executable} #{@command} #{controlrepo_param}"
  end

  def to_s
    return generate_command
  end

end
