Given(/^onceover executable$/) do
  @cmd = Command_Helper.new
end

Given(/^control repo "([^"]*)"$/) do |controlrepo_name|
  @repo = ControlRepo_Helper.new( controlrepo_name )
  @cmd.controlrepo = @repo
  FileUtils.rm_rf @repo.root_folder
  FileUtils.mkdir_p @repo.tmp_folder

  FileUtils.rm_rf "#{@repo.tmp_folder}#{controlrepo_name}"
  FileUtils.cp_r "spec/fixtures/controlrepos/#{controlrepo_name}", @repo.tmp_folder
end

Given(/^existing control repo "([^"]*)"$/) do |controlrepo_name|
  @repo = ControlRepo_Helper.new( controlrepo_name )
  @cmd.controlrepo = @repo
end

Given(/^initialized control repo "([^"]*)"$/) do |controlrepo_name|
  step %Q(control repo "#{controlrepo_name}")
  step %Q(I run onceover command "init")
end

Given(/^control repo "([^"]*)" without "([^"]*)"$/) do |controlrepo_name, filename|
  step %Q(control repo "#{controlrepo_name}")
  FileUtils.rm_rf "#{@repo.root_folder}/#{filename}"
end

When(/^I run onceover command "([^"]*)"$/) do |command|
  @cmd.command = "#{command} --debug"
  log(@cmd)
  @cmd.run
end

When(/^I run onceover command "([^"]*)" with class "([^"]*)"$/) do |command, cls|
  @cmd.command = "#{command} --classes #{cls}"
  log(@cmd)
  @cmd.run
end

When(/^I run onceover command "([^"]*)" with class "([^"]*)" on nodes "([^"]*)"$/) do |command, cls, nodes|
  @cmd.command = "#{command} --classes #{cls} --nodes #{nodes}"
  log(@cmd)
  @cmd.run
end

# The below can be used to skip tests if they only work on one os
When(/^test osfamily is "(\w*)"$/) do |osfamily|
  require 'facter'
  pending unless Facter.value(:os)['family'] == osfamily
end

When(/^test osfamily is not "(\w*)"$/) do |osfamily|
  require 'facter'
  pending if Facter.value(:os)['family'] == osfamily
end

Then(/^I see help for commands: "([^"]*)"$/) do |commands|
  # Get chunk of output between COMMANDS and OPTION, there should be help section
  commands_help = @cmd.output[/COMMANDS(.*)OPTIONS/m, 1]
  commands.split(',').each do |command|
    result = commands_help.match(/^\s+#{command.strip}.+\n/)
    log(result.to_s) if expect(result).not_to be nil
  end
end

Then(/^I should not see any errors$/) do
  log(@cmd.output) unless @cmd.success?
  expect(@cmd.success?).to be true
end

Then(/^the config should contain "([^"]*)"$/) do |pattern|
  pattern = Regexp.new(pattern)
  expect(@repo.config_file_contents).to match(pattern)
end

Then(/^Onceover should exit (\d+)$/) do |code|
  expect(@cmd.exit_code).to eq code.to_i
end

Then(/^I should see error with message pattern "([^"]*)"$/) do |err_msg_regexp|
  expect(@cmd.success?).to be false
  log(@cmd.output)
  expect(@cmd.output.match err_msg_regexp).to_not be nil
end

Then(/^I should (not )?see message pattern "([^"]*)"$/) do |notword, msg_regexp|
  output_surround = 30
  match = Regexp.new(msg_regexp).match(@cmd.output)
  
  # Expect it to match unless we said it shouldn't match
  expected_match = notword.nil?
  does_match = !match.nil?

  if expected_match
    expect(@cmd.output).to match(msg_regexp)
  else
    expect(@cmd.output).not_to match(msg_regexp)
  end

  # If the regex matches and that's what we expected then just print a summary
  if does_match == expected_match
    if match
      log(match.pre_match[-output_surround..-1] + match.to_s + match.post_match[0..output_surround])
    end
  else
    log(@cmd.output)
  end
end

When(/^I run onceover command "([^"]*)" with \-\-puppetfile ([^"]*)$/) do |command, puppetfile|
  puppetfile_path = @repo.root_folder + puppetfile
  @cmd.command = "#{command} --puppetfile #{puppetfile_path} --debug"
  log(@cmd)
  @cmd.run
end

Then(/^([^"]*) should be copied to Puppetfile$/) do |puppetfile|
  source = @repo.root_folder + puppetfile
  destination = @repo.onceover_temp_puppetfile
  expect(IO.read(source)).to eq(IO.read(destination))
end
