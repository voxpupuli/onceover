require 'spec_helper'
require 'onceover/controlrepo'

describe "Onceover::Controlrepo" do
  context "in a barebones controlrepo" do
    before do
      @repo = Onceover::Controlrepo.new(
        {
          path:'spec/fixtures/controlrepo_minimal'
        }
      )
    end

    context "without hiera.yaml" do
      it { expect(@repo.hiera_config_file_relative_path).to be_nil }
    end
  end
end
