require 'spec_helper'

describe 'Simplib::Cron::WeekDay_entry' do
  context 'with valid parameters' do
    it { is_expected.to allow_value( 0 ) }
    it { is_expected.to allow_value( '0' ) }
    it { is_expected.to allow_value( 2 ) }
    it { is_expected.to allow_value( '2' ) }
    it { is_expected.to allow_value( '7' ) }  #Sunday can be 0 or 7
    it { is_expected.to allow_value( 7 ) }  #Sunday can be 0 or 7
    it { is_expected.to allow_value( 'SUN' ) }
    it { is_expected.to allow_value( 'sun' ) }
    it { is_expected.to allow_value( '*' ) }
    it { is_expected.to allow_value( '*/5' ) }
    it { is_expected.to allow_value( '0-4' ) }
    it { is_expected.to allow_value( '0-6/2' ) }
  end
  context 'with invalid parameters' do
    it { is_expected.not_to allow_value( 'SUN,MON,WED,TUE' ) }
    it { is_expected.not_to allow_value( 'SUNDAY' ) }
    it { is_expected.not_to allow_value( '1,4-5' ) }
    it { is_expected.not_to allow_value( '1,MON,3,5' ) }
    it { is_expected.not_to allow_value( 'TUE-FRI' ) }
    it { is_expected.not_to allow_value( 'TUE-5' ) }
    it { is_expected.not_to allow_value( 'TUE/3' ) }
    it { is_expected.not_to allow_value( '/3' ) }
    it { is_expected.not_to allow_value( '-2' ) }
    it { is_expected.not_to allow_value( '9' ) }
    it { is_expected.not_to allow_value( '3/*' ) }
    it { is_expected.not_to allow_value( '3/5' ) }
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
