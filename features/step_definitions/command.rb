require "open3"

class Command

  attr_reader(:output, :result)

  attr_writer(:command, :params, :controlrepo)

  def initialize
    @executable = ENV["BUNDLE_GEMFILE"] ? "bundle exec onceover" : "onceover"
  end

  def run
    controlrepo_param = @controlrepo ? "--path tmp/tests/#{@controlrepo}" : ''
    full_cmd = "#{@executable} #{@command} #{controlrepo_param}"
    @output, @result = Open3.capture2e full_cmd
  end

  def success?
    return @result.success?
  end

  def to_s
    controlrepo_param = @controlrepo ? "--path tmp/tests/#{@controlrepo}" : ''
    return "#{@executable} #{@command} #{controlrepo_param}"
  end

end
