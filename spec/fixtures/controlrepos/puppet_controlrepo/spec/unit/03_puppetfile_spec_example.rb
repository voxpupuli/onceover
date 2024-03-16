#
# This set of tests ensures that the Puppetfile has been written correctly
# Anything relating to the syntax or content of the Puppetfile should be
# in this file
#
require 'r10k/puppetfile'

describe "The Puppetfile" do
  # Load in the Puppetfile using the r10k gem
  # This handles all of the parsing for us so that we don't need to write
  # complicated regular expressions or anything like that.
  @puppetfile = R10K::Puppetfile.new('./etc/puppetlabs/code/environments/production')
  @puppetfile.load!

  @puppetfile.modules.each do |current_module|
    describe current_module.name do
      #require 'pry'
      #binding.pry
      it "should be pinned to a version" do
        if current_module.is_a? R10K::Module::Git
          # It should be pinned to a version or commit
          semver_regex = /^v?\d+\.?\d*\.*\w*$/
          commit_regex = /^[0-9a-f]{7,40}$/
          expect(current_module.version).to match Regexp.union(semver_regex,commit_regex)
        else
          # If it's a forge module it should not be pinned to latest
          expect(current_module.instance_variable_get('@args')).not_to eq(:latest)
          # It should also not have blank args
          expect(current_module.instance_variable_get('@args')).not_to eq(nil)
        end
      end
    end
  end

end
