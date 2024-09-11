require 'spec_helper'

describe 'opendkim', :type => :class do

  describe "Opendkim class with no parameters, basic test" do
    let(:params) { { } }

      it {
        should contain_package('opendkim')
        should contain_service('opendkim')
      }
  end
end
