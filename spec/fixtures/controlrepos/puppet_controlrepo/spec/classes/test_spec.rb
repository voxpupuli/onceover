require 'spec_helper'

describe "role::dbserver" do
  context "With no facts" do
    let(:facts) { { } }
    it { should_not compile }
  end
end
