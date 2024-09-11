require 'spec_helper'

describe 'kmod::setting', type: :define do
  let(:title) { 'foo' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(augeasversion: '1.2.0')
      end

      let(:default_params) { { file: 'modprobe.conf' } }
      let(:params) { default_params }

      context 'add an alias' do
        let(:params) { default_params.merge(category: 'alias', option: 'modulename', value: 'tango') }

        it { is_expected.to contain_kmod__setting('foo') }
        it {
          is_expected.to contain_augeas('kmod::setting foo foo')
            .with('incl'    => 'modprobe.conf',
                  'lens'    => 'Modprobe.lns',
                  'changes' => ["set alias[. = 'foo'] foo", "set alias[. = 'foo']/modulename tango"],
                  'require' => 'File[modprobe.conf]')
        }
      end
      context 'add a blacklist' do
        let(:params) { { file: '/etc/modprobe.d/blacklist.conf', category: 'blacklist' } }

        it { is_expected.to contain_kmod__setting('foo') }
        it {
          is_expected.to contain_augeas('kmod::setting foo foo')
            .with('incl'    => '/etc/modprobe.d/blacklist.conf',
                  'lens'    => 'Modprobe.lns',
                  'changes' => ["set blacklist[. = 'foo'] foo"],
                  'require' => 'File[/etc/modprobe.d/blacklist.conf]')
        }
      end
    end
  end
end
