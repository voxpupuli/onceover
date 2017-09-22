require 'spec_helper'
require 'onceover/facter'

describe 'Onceover::Facter' do

  subject(:facter) { Onceover::Facter.new }

  describe '.os_names' do
    it { expect(facter.os_names).to be_instance_of Array }
  end

  describe '.windows_os_names' do
    it { expect(facter.windows_os_names).to be_instance_of Array }
  end

  describe '.facts_by_os' do
    context 'for Debian-8-i386 OS' do
      it 'should returns facts for specific OS' do
        facts = facter.facts_by_os('Debian-8-i386')
        expect(facts).to be_instance_of Hash
        expect(facts[:operatingsystem]).to eq('Debian')
        expect(facts[:operatingsystemmajrelease]).to eq('8')
        expect(facts[:architecture]).to eq('i386')
      end
    end

    # TODO: Turn it on if https://github.com/camptocamp/facterdb/issues/58 would be fixed
    # context 'for Non_Existed OS' do
    #   it 'should raise exception' do
    #     expect { facter.facts_by_os('Non_Existed') }.to raise_error(RuntimeError, /Should returns only one facts set, returns 0/)
    #   end
    # end
  end

end

