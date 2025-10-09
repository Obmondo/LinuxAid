# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog::Actions::Outputs::Ommail' do
  let(:data) do
    {
      server: 'mail.example.com',
      port: 25,
      mailfrom: 'user@example.com',
      mailto: 'user2@example.com',
      'subject.template' => 'subject_temp',
      'subject.text' => 'Test Subject',
      'body.enable' => 'on',
      template: 't_mail'
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
          server: '192.16.2.',
          port: '80',
          mailfrom: 'user',
          mailto: 'user2',
          'subject.template' => 1,
          'subject.text' => '',
          'body.enable' => true,
          template: ''
        }
      end

      it { is_expected.not_to allow_value(bad_strings) }
    end
  end
end
