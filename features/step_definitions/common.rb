Given /^onceover executable$/ do
  @cmd = Command.new
end

Given(/^control repo "([^"]*)"$/) do |controlrepo_name|
  @cmd.controlrepo = controlrepo_name
  FileUtils.rm_rf "tmp/tests/#{controlrepo_name}"
  FileUtils.mkdir_p 'tmp/tests'
  FileUtils.cp_r "spec/fixtures/#{controlrepo_name}", 'tmp/tests'
end

Given(/^initialized control repo "([^"]*)"$/) do |controlrepo_name|
  step %Q(control repo "#{controlrepo_name}")
  step %Q(I run onceover command "init")
end

Given(/^control repo "([^"]*)" without "([^"]*)"$/) do |controlrepo_name, filename|
  step %Q(control repo "#{controlrepo_name}")
  controlrepo_path = "tmp/tests/#{controlrepo_name}"
  FileUtils.rm_rf( controlrepo_path + "/#{filename}" )
end


Then(/^I should see all tests pass$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

When /^I run onceover command "([^"]*)"$/  do |command|
  @cmd.command = command
  puts @cmd
  @cmd.run
end

Then /^I see help for commands: "([^"]*)"$/ do |commands|
  # Get chunk of output between COMMANDS and OPTION, there should be help section
  commands_help = @cmd.output[/COMMANDS(.*)OPTIONS/m, 1]
  commands.split(',').each do |command|
    result = commands_help.match(/^\s+#{command.strip}.+\n/)
    puts result.to_s if expect(result).not_to be nil
  end
end

Then(/^I should not see any errors$/) do
  expect(@cmd.success?).to be true
end

Then(/^I should see error with message pattern "([^"]*)"$/) do |err_msg_regexp|
  expect(@cmd.success?).to be false
  puts @cmd.output
  expect(@cmd.output.match err_msg_regexp).to_not be nil
end

Then(/^I should see generated all necessary files and folders$/) do
  controlrepo_path = "tmp/tests/controlrepo_basic/"
  files = [ 'spec/onceover.yaml', 'Rakefile', 'Gemfile' ].map { |x| controlrepo_path + x }
  folders = [ 'spec/factsets', 'spec/pre_conditions'].map! { |x| controlrepo_path + x}

  files.each do |file|
    puts file
    expect( File.exist? file ).to be true
  end
  folders.each do |folder|
    puts folder
    expect( Dir.exist? folder ).to be true
  end
end
