Then(/^the cache should exist$/) do
  cache_dir = File.join(@repo.root_folder,'.onceover')
  expect(File.directory?(cache_dir)).to be true
end

Then(/^the cache should contain all controlrepo files/) do
  # Get all root files
  puts "Calculating MD5 hashes in repo"
  repo_digest = Cache_Helper.digest(@repo.root_folder)
  puts "#{repo_digest.count} MD5 hashes calculated"
  puts "Calculating MD5 hashes in cache"
  cache_digest = Cache_Helper.digest(File.join(@repo.root_folder,'.onceover/etc/puppetlabs/code/environments/production/'))
  puts "#{cache_digest.count} MD5 hashes calculated"
  expect(cache_digest).to include(repo_digest)
end

When(/^I (\w+) a file "(.*)"$/) do |action,file|
  require 'securerandom'
  actual_file = Pathname.new(File.join(@repo.root_folder,file))
  case action
  when "create"
    FileUtils.mkdir_p(actual_file.dirname)
    File.write(actual_file,SecureRandom.hex)
  when "delete"
    FileUtils.rm(actual_file)
  end
end

Then(/^"(.*)" should be cached correctly$/) do |file|
  original_digest = Cache_Helper.digest(File.join(@repo.root_folder,file))
  cache_digest    = Cache_Helper.digest(File.join(@repo.root_folder,'.onceover/etc/puppetlabs/code/environments/production/',file))
  expect(original_digest).to include(cache_digest)
end

Then(/^"([^"]*)" should be deleted from the cache$/) do |file|
  deleted_file = Pathname.new(File.join(@repo.root_folder,'.onceover/etc/puppetlabs/code/environments/production/',file))
  expect(deleted_file.exist?).to be false
end
