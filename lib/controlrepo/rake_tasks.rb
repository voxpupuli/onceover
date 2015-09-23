require 'controlrepo'

task :controlrepo_generate_fixtures do
  repo = Controlrepo.new
  puts repo.fixtures
end