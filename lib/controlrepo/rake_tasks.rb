require 'controlrepo'

task :generate_tests do
  repo = Controlrepo.new
  puts repo.fixtures
  puts repo.config
end