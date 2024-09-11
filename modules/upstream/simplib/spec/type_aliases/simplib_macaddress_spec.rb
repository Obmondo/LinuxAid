require 'spec_helper'

describe 'Simplib::Macaddress' do
  context 'with valid MAC addresses' do
    it { is_expected.to allow_value('CA:FE:BE:EF:00:11') }
    it { is_expected.to allow_value('ca:fe:be:ef:00:11') }
    it { is_expected.to allow_value('12:34:56:78:90:11') }
    it { is_expected.to allow_value('Ca:fE:0e:F1:00:11') }
    it { is_expected.to allow_value('0:1:2:3:4:5') }
    it { is_expected.to allow_value('A0:B:2C:D:E4:F') }
  end

  context 'with invalid MAC addresses' do
    it { is_expected.not_to allow_value('CA:FE:BE:EF:00:') }
    it { is_expected.not_to allow_value('CA:FE:BE:EF::11') }
    it { is_expected.not_to allow_value('OO:PS:NO:TH:EX:11') }
  end
end
