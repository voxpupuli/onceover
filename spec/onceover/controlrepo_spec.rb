require 'spec_helper'
require 'onceover/controlrepo'

describe "Onceover::Controlrepo" do
  before do
    @repo = Onceover::Controlrepo.new(
      {
        path:'spec/fixtures/controlrepo'
      }
    )
  end

  context ".hiera_config_file_relative_path" do
    context "without hiera.yaml" do
      it { expect(@repo.hiera_config_file_relative_path).to be_nil }
    end
  end
end
