require 'spec_helper'

describe 'kmod::alias', type: :define do
  let(:title) { 'foo' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(augeasversion: '1.2.0')
      end

      let(:default_params) { { source: 'bar', file: '/baz' } }

      context 'when a file is specified' do
        let(:params) { default_params }

        it { is_expected.to contain_kmod__alias('foo') }
        it {
          is_expected.to contain_kmod__setting('kmod::alias foo')
            .with('ensure'    => 'present',
                  'module'    => 'foo',
                  'file'      => '/baz',
                  'category'  => 'alias',
                  'option'    => 'modulename',
                  'value'     => 'bar')
        }
      end

      context 'when a file is specified and an aliasname' do
        let(:params) { default_params.merge!(aliasname: 'tango') }

        it { is_expected.to contain_kmod__alias('foo') }
        it {
          is_expected.to contain_kmod__setting('kmod::alias foo')
            .with('ensure'    => 'present',
                  'module'    => 'tango',
                  'file'      => '/baz',
                  'category'  => 'alias',
                  'option'    => 'modulename',
                  'value'     => 'bar')
        }
      end

      context 'when ensure absent is specified' do
        let(:params) { default_params.merge!(ensure: 'absent') }

        it { is_expected.to contain_kmod__alias('foo') }
        it {
          is_expected.to contain_kmod__setting('kmod::alias foo')
            .with('ensure'    => 'absent')
        }
      end
    end
  end
end
