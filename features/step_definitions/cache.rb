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
  require 'pry'
  expect(cache_digest).to include(repo_digest)
end

When(/^I create a file "(.*)"$/) do |file|
  require 'securerandom'

  File.write(File.join(@repo.root_folder,file),SecureRandom.hex)
end

Then(/^"(.*)" should be cached correctly$/) do |file|
  original_digest = Cache_Helper.digest(File.join(@repo.root_folder,file))
  cache_digest    = Cache_Helper.digest(File.join(@repo.root_folder,'.onceover/etc/puppetlabs/code/environments/production/',file))
  expect(original_digest).to include(cache_digest)
end
