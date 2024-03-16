#
# This set of tests is for syntax validation, It runs through all of the
# Puppet, Ruby and ERB code in the repositories and validates it with it's
# relevant validator.
#
# If we want to change the scope of these tests the following variables can be
# modified to change which files are in scope:
#   - puppet_search_path
#   - ruby_search_path
#   - erb_search_path
#   - epp_search_path
#
# All paths are relative the the .onceover temporary directory which is created
# as part of a normal Onceover run
require 'puppet'

# Tell Puppet where to find our code. This is relative to the .onceover directory
Puppet.initialize_settings(['--codedir ./etc/puppetlabs/code'])

# Create a Puppet environment that we can interact with
env = Puppet.lookup(:current_environment)
loaders = Puppet::Pops::Loaders.new(env)

# Where to search fort files to syntax validate
puppet_search_path = './etc/puppetlabs/code/environments/production/site-modules/*/{manifests,functions,types}/**/*.pp'
ruby_search_path   = './etc/puppetlabs/code/environments/production/site-modules/*/lib/**/*.rb'
erb_search_path    = './etc/puppetlabs/code/environments/production/site-modules/**/*.erb'
epp_search_path    = './etc/puppetlabs/code/environments/production/site-modules/**/*.epp'

describe "When checking Puppet syntax", syntax: true do
  Dir[puppet_search_path].each do |manifest|
    context manifest do
      it "should be valid Puppet syntax" do
        Puppet.override({ :loaders => loaders }, 'For Puppet parser validate') do
          validation_environment = env.override_with(:manifest => manifest)
          expect(validation_environment.check_for_reparse).to be_nil
          expect(validation_environment.known_resource_types.clear).to match_array []
        end
      end
    end
  end
end

describe "When checking Ruby syntax", syntax: true do
  Dir[ruby_search_path].each do |ruby_file|
    context ruby_file do
      it "should be valid Ruby syntax" do
        expect(`ruby -c #{ruby_file}`).to match(/Syntax OK/) unless ruby_file =~ /spec\/fixtures/
      end
    end
  end
end

describe "When checking ERB syntax", syntax: true do
  Dir[erb_search_path].each do |template|
    context template do
      it "should be valid ERB syntax" do
        expect(`erb -P -x -T '-' #{template} | ruby -c`).to match(/Syntax OK/)
      end
    end
  end
end

describe "When checking EPP syntax", syntax: true do
  before(:all) do
    @parser = Puppet::Pops::Parser::EvaluatingParser::EvaluatingEppParser.new()
  end

  Dir[epp_search_path].each do |template|
    context template do
      it "should be valid EPP syntax" do
        expect{@parser.parse_file(template)}.not_to raise_error
      end
    end
  end
end
