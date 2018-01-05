require 'spec_helper'
require 'onceover/controlrepo'

describe "Onceover::Controlrepo" do
  context "in a complex repo" do
    before do
      @repo = Onceover::Controlrepo.new(
        {
          path:'spec/fixtures/controlrepos/puppet_controlrepo'
        }
      )
    end

    context "when initialising the object" do
      it { expect(@repo).not_to be_nil }
    end

    context "when running the tests" do
      it "doesn't die horribly" do
        expect{
          Dir.chdir('spec/fixtures/controlrepos/puppet_controlrepo') do
            require 'onceover/controlrepo'
            require 'onceover/cli'
            require 'onceover/runner'
            require 'onceover/testconfig'
            require 'onceover/logger'

            repo = Onceover::Controlrepo.new({})
            runner = Onceover::Runner.new(repo,Onceover::TestConfig.new(repo.onceover_yaml, {}), :spec)
            runner.prepare!
            runner.run_spec!
          end
        }.not_to raise_error
      end
    end
  end
end
