require 'spec_helper'

describe 'Simplib::Cron::Month_entry' do
  context 'with valid parameters' do
    it { is_expected.to allow_value( '2' ) }
    it { is_expected.to allow_value( 2 ) }
    it { is_expected.to allow_value( 'JAN' ) }
    it { is_expected.to allow_value( 'jan' ) }
    it { is_expected.to allow_value( '*' ) }
    it { is_expected.to allow_value( '*/5' ) }
    it { is_expected.to allow_value( '2-10' ) }
    it { is_expected.to allow_value( '2-10/2' ) }
  end
  context 'with invalid parameters' do
    it { is_expected.not_to allow_value( '1,3-5' ) }
    it { is_expected.not_to allow_value( 'JAN,MAR,JUN,APR' ) }
    it { is_expected.not_to allow_value( 'APRIL' ) }
    it { is_expected.not_to allow_value( 'APR-JUN' ) }
    it { is_expected.not_to allow_value( '-2' ) }
    it { is_expected.not_to allow_value( '/3' ) }
    it { is_expected.not_to allow_value( '1,FEB,3,5' ) }
    it { is_expected.not_to allow_value( 'FEB-5' ) }
    it { is_expected.not_to allow_value( 'FEB/3' ) }
    it { is_expected.not_to allow_value( '0' ) }
    it { is_expected.not_to allow_value( '13' ) }
    it { is_expected.not_to allow_value( '3/*' ) }
    it { is_expected.not_to allow_value( '2/10' ) }
    it { is_expected.not_to allow_value( '3-/5' ) }
  end
  context 'with silly things' do
    it { is_expected.not_to allow_value( []) }
    it { is_expected.not_to allow_value( '.') }
    it { is_expected.not_to allow_value( '' ) }
    it { is_expected.not_to allow_value( "1  ") }
    it { is_expected.not_to allow_value( "5 1") }
    it { is_expected.not_to allow_value( :undef) }
  end
end
