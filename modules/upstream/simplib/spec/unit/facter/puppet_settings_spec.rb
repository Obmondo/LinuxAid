require 'spec_helper'
#require 'facter/puppet_settings'

describe "custom fact puppet_settings" do

  before(:each) do
    if Facter.collection.respond_to?(:load)
      Facter.collection.load(:puppet_settings)
    else
      Facter.collection.loader.load(:puppet_settings)
    end
  end

  it 'should return hash of puppet settings' do
      settings = Facter.fact(:puppet_settings).value
      expect(settings).to include('main')
      keys_of_interest = [
        'certdir',
        'confdir',
        'environment',
        'environmentpath',
        'libdir',
        'logdir',
        'path',
        'rundir',
        'ssldir',
        'vardir'
      ]
      expect(settings['main']).to include(*keys_of_interest)
  end
end
