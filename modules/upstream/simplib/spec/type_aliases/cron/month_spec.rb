require 'spec_helper'

describe 'Simplib::Cron::Month' do
  context 'with valid parameters' do
    it { is_expected.to allow_value( [12] ) }
    it { is_expected.to allow_value( ['12'] ) }
    it { is_expected.to allow_value( ['dec'] ) }
    it { is_expected.to allow_value( ['DEC'] ) }
    it { is_expected.to allow_value( ['10-11','DEC','jan','1-6/2',3,5,'9'] ) }
    it { is_expected.to allow_value( 12 ) }
    it { is_expected.to allow_value( '12' ) }
    it { is_expected.to allow_value( 'DEC' ) }
    it { is_expected.to allow_value( '2-3' ) }
    it { is_expected.to allow_value( '*' ) }
    it { is_expected.to allow_value( '*/5' ) }
    it { is_expected.to allow_value( '1-12/2' ) }
  end
  context 'with invalid parameters' do
    it { is_expected.not_to allow_value( ['10-12','1-6/2',3,0,'MAY','9'] ) }
    it { is_expected.not_to allow_value( ['0,1,11-12,5'] ) }
    it { is_expected.not_to allow_value( ["'3','1','10-12','5'"] ) }
  end
end
