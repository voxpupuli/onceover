#
# The following set of tests is designed to enforce style in the Puppet code.
# This may be coming from the Puppet style guide as in the puppet-lint tests
# or may be arbitrarily defined. Anything that relates to how the
# code is written should go in this file
#
require 'puppet-lint'

# Create a single linter object to save time
linter = PuppetLint.new

# --- Begin Settings ---
#
manifest_search_path = './etc/puppetlabs/code/environments/production/site/*/manifests/**/*.pp'

# Options passed to puppet-lint
# See http://puppet-lint.com/checks/
linter.configuration.ignore_paths = ["spec/**/*.pp", "pkg/**/*.pp"]
# I would like to enable this soon
linter.configuration.send('disable_documentation')
# We just don't care about this stuff
linter.configuration.send('disable_80chars')
linter.configuration.send('disable_140chars')
# linter.configuration.send('disable_names_containing_uppercase')
#linter.configuration.send('disable_double_quoted_strings')
#linter.configuration.send('disable_variable_scope')
#linter.configuration.send('disable_slash_comments')
#linter.configuration.send('disable_autoloader_layout')
#linter.configuration.send('disable_star_comments')
#linter.configuration.send('disable_variables_not_enclosed')
#linter.configuration.send('disable_arrow_alignment')
#linter.configuration.send('disable_trailing_whitespace')
# At the moment this is broken, identifying local variables
# in iterations as top level. Can surround the code block
# with the following comments:
# lint:ignore:variable_scope
# lint:endignore

# Set up the Linter error message, this is not normally required but
# in this instance it was cutting off useful information so we are
# creating a custom error message/
def format_error(problems)
  problems.map do |problem|
    problem.keep_if do |k,v|
      [:message,:line,:column,:check].include?(k)
    end
  end.to_yaml
end


# --- End Settings ---
require 'yaml'

describe "When checking Puppet Style" do
  Dir[manifest_search_path].each do |manifest|
    context manifest do
      it "should follow the style guide" do
        linter.file = manifest
        expect(linter.run).to be nil

	      # Get all of the problems that were not ignored
        problems = linter.problems.reject {|r| r[:kind] == :ignored }

        # Expect there to be no problems, but also format the errors nicely
        expect(problems).to match_array([]), format_error(problems)
      end
    end
  end
end
