require 'pry'
require 'r10k/puppetfile'

desc "Generate"

task :generate_tests do
  cwd = File.dirname(__FILE__)
  puts "Loading Puppetfile: #{cwd}"
  puppetfile = R10K::Puppetfile.new(cwd)
end