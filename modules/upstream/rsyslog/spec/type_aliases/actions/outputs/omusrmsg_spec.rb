# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog::Actions::Outputs::Omusrmsg' do
  let(:data) do
    {
      users: '*',
      template: 't_usr_msg'
    }
  end

  context 'with valid data' do
    context 'full data' do
      it { is_expected.to allow_value(data) }
    end
  end

  context 'with invalid data' do
    context 'bad strings' do
      let(:bad_strings) do
        {
          users: 0,
          template: false
        }
      end

      it { is_expected.not_to allow_value(bad_strings) }
    end
  end
end
