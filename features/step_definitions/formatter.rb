Given(/^the OnceoverFormatter$/) do
  require 'rspec'
  require 'onceover/rspec/formatters'

  RSpec.configure do |c|
    # Create onceover settings to be accessed by formatters
    c.add_setting :onceover_tempdir
    c.add_setting :onceover_root
    c.add_setting :onceover_environmentpath
  
    c.onceover_tempdir         = "/Users/foo/git/controlrepo/.onceover"
    c.onceover_root            = "/Users/foo/git/controlrepo"
    c.onceover_environmentpath = "etc/puppetlabs/code/environments"
  end
  
  @formatter = OnceoverFormatter.new(STDOUT)
end

When(/^Puppet throws the error: "(.*)"$/) do |error|
  @error = error
end

Then(/^the error should parse successfully$/) do
  expect do
    @parsed_error = @formatter.parse_errors(@error)
  end.to_not raise_error
end

Then(/^it should find (\d+) errors?$/) do |number|
  expect(@parsed_error.length).to be(number.to_i)
end

Then(/^the parsed errors? should contain the following keys: (.*)$/) do |keys|
  # Split the keys into an array
  keys = keys.split(',').map(&:strip)
  @parsed_error.each do |error|
    keys.each do |k|
      expect(error).to have_key(k.to_sym)
    end
  end
end