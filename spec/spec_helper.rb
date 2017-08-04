$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require "rspec"

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
end
