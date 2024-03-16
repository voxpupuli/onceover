Then(/^the temporary Puppetfile should contain \/(.*)\/$/) do |regex|
  puppetfile = File.read(@repo.onceover_temp_puppetfile)
  expect(puppetfile).to match(Regexp.new(regex))
end

Then(/^the temporary Puppetfile should contain the git branch/) do
  git_branch = `git rev-parse --abbrev-ref HEAD`.chomp
  step %Q(the temporary Puppetfile should contain /#{git_branch}/)
end

When(/^I make local modifications$/) do
  FileUtils.rm_rf("#{@repo.onceover_temp_root_folder}/modules/apache/manifests")
end

Before('@skip_on_windows') do
  skip_this_scenario if RUBY_PLATFORM =~ /mswin|mingw/
end
