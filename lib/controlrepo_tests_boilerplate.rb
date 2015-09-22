require 'pry'
require 'r10k/puppetfile'

desc "Generate"

task :generate_tests do
  # Load up the Puppetfile using R10k
  puppetfile = R10K::Puppetfile.new(Dir.pwd)
  modules = puppetfile.load

  # Iterate over everything and seperate it out for the sake of readability
  symlinks = []
  forge_modules = []
  repositories = []

  modules.each do |mod|
    # This logic could probably be cleaned up. A lot.
    if mod.is_a? R10K::Module::Forge
      if mod.expected_version.is_a?(Hash)
        # Set it up as a symlink, because we are using local files in the Puppetfile
        symlinks << {
          'name' => mod.name,
          'dir' => mod.expected_version[:path]
        }
      elsif mod.expected_version.is_a?(String)
        # Set it up as a normal firge module
        forge_modules << {
          'name' => mod.name,
          'repo' => mod.title,
          'ref' => mod.expected_version
        }
      end
    elsif mod.is_a? R10K::Module::Git
      # Set it up as a git repo
      repositories << {
          'name' => mod.name,
          'repo' => mod.instance_variable_get(:@remote),
          'ref' => mod.version
        }
    end
  end
  puts "Repos: #{repositories}"
  puts "Synlinks: #{symlinks}"
  puts "Forge Modules #{forge_modules}"
  puts "LOAD_PATH: #{$LOAD_PATH}"
end