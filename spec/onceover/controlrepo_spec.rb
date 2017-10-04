require 'spec_helper'
require 'onceover/controlrepo'

describe "Onceover::Controlrepo" do
  subject(:repo) { Onceover::Controlrepo.new({ path:'spec/fixtures/controlrepo_minimal' }) }

  context "#facter" do
    it { expect(repo.facter).to be_instance_of Onceover::Facter }
  end

  context "without hiera.yaml" do
    it { expect(repo.hiera_config_file_relative_path).to be_nil }
  end

end
