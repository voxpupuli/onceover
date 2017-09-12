Given /^onceover executable$/  do
  @executable = ENV["BUNDLE_GEMFILE"] ? "bundle exec onceover " : "onceover "
end

When /^I run onceover command "([^"]*)"$/  do |arg1|
  command = @executable + arg1
  puts command
  @output = `#{command}`
  expect($?.success?).to be true
end

Then /^I see help for commands: "([^"]*)"$/ do |commands|
  commands_help = @output[/COMMANDS(.*)OPTIONS/m, 1]
  commands.split(',').each do |command|
    result = commands_help.match(/^\s+#{command.strip}.+\n/)
    puts result.to_s if expect(result).not_to be nil
  end
end
