require 'spec_helper'

shared_examples_for 'test_linux' do |fact_set|

  describe "SOE Checks" do

    it do
      is_expected.to contain_package('tree').with(
        'ensure'  => 'latest',
      )
    end

    it do
      is_expected.to contain_package('vim').with(
        'ensure'  => 'latest',
      )
    end

    it do
      is_expected.to contain_package('git').with(
        'ensure'  => 'latest',
      )
    end

    it do
      is_expected.to contain_package('htop').with(
        'ensure'  => 'latest',
      )
    end

    it do
      is_expected.to contain_package('zlib').with(
        'ensure'  => 'latest',
      )
    end

    it do
      is_expected.to contain_package('zlib-devel').with(
        'ensure'  => 'latest',
      )
    end

    it do
      is_expected.to contain_package('jq').with(
        'ensure'  => 'latest',
      )
    end

    it do
      is_expected.to contain_package('ruby').with(
        'ensure'  => 'latest',
      )
    end

    it do
      is_expected.to contain_package('ruby-devel').with(
        'ensure'  => 'latest',
      )
    end

    it do
      is_expected.to contain_package('multitail').with(
        'ensure'  => 'latest',
      )
    end

    it do
      is_expected.to contain_package('haveged').with(
        'ensure'  => 'latest',
      )
    end

    it do
      is_expected.to contain_package('cmake').with(
        'ensure'  => 'latest',
      )
    end

    it do
      is_expected.to contain_package('tmux').with(
        'ensure'  => 'latest',
      )
    end

    it do
      is_expected.to contain_package('unzip').with(
        'ensure'  => 'latest',
      )
    end
  end
end
