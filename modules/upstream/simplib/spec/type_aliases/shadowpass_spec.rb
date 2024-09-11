require 'spec_helper'

describe 'Simplib::ShadowPass' do
  context 'with valid entries' do
    it { is_expected.to allow_value('*') }
    it { is_expected.to allow_value('!') }
    it { is_expected.to allow_value('!!') }
    it { is_expected.to allow_value('!!i$6$h6k81gwg$J5QJ3DWz9G2CeIHMEXRfhd7Ocem.NNfQimxw/OUa2m/PD3Mx6q67ntjELlVgye4kHxG5ZfMAXLjioGWISJYFE1') }
    it { is_expected.to allow_value('$6$h6k81gwg$J5QJ3DWz9G2CeIHMEXRfhd7Ocem.NNfQimxw/OUa2m/PD3Mx6q67ntjELlVgye4kHxG5ZfMAXLjioGWISJYFE1') }
    it { is_expected.to allow_value('$5$4E8kXNLiykgBk$NviJTE3NgOvqoF0hXlhFbbYknIpTZqqVqihav8ZM2h9') }
    it { is_expected.to allow_value('$3$$0480cf9c8755c691c629f6595c2e7238') }
    it { is_expected.to allow_value('$2a$07$ybS56Js6xCcu5SxFwa2NsODRF109WEitIY52THiZh.eFdfQg8ovNe') }
    it { is_expected.to allow_value('$2y$10$RT.Z68QWbhbg5.TOba4gGOBEvj6anWfvPBaU3F1HMHTSz5g75Vrme') }
    it { is_expected.to allow_value('$1$0nIBDEfm$QNNyqbDS5ZkwScfmvI37z.') }
  end

  context 'with invalid entries' do
    it { is_expected.not_to allow_value('*$6$h6k81gwg$J5QJ3DWz9G2CeIHMEXRfhd7Ocem.NNfQimxw/OUa2m/PD3Mx6q67ntjELlVgye4kHxG5ZfMAXLjioGWISJYFE1') }
    it { is_expected.not_to allow_value('$6$') }
    it { is_expected.not_to allow_value('mycleartextpassword') }
  end
end
