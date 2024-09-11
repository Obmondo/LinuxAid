require 'spec_helper'

describe 'jenkins::job' do
  let(:title) { 'myjob' }

  let :pre_condition do
    'include jenkins'
  end

  on_supported_os.each do |os, facts|
    context "on #{os} " do
      systemd_fact = case facts[:operatingsystemmajrelease]
                     when '6'
                       { systemd: false }
                     else
                       { systemd: true }
                     end
      let :facts do
        facts.merge(systemd_fact)
      end

      describe 'relationships' do
        quotes = "<xml version='1.0' encoding='UTF-8'></xml>"
        let(:params) { { config: quotes } }

        it do
          is_expected.to contain_jenkins__job('myjob').
            that_requires('Class[jenkins::cli]')
        end
        it do
          is_expected.to contain_jenkins__job('myjob').
            that_comes_before('Anchor[jenkins::end]')
        end
      end

      describe 'with defaults' do
        quotes = "<xml version='1.0' encoding='UTF-8'></xml>"
        let(:params) { { config: quotes } }

        it { is_expected.to contain_exec('jenkins create-job myjob') }
        it { is_expected.to contain_exec('jenkins update-job myjob') }
        it { is_expected.not_to contain_exec('jenkins delete-job myjob') }
      end

      describe 'with job present' do
        quotes = "<xml version='1.0' encoding='UTF-8'></xml>"
        let(:params) { { ensure: 'present', config: quotes } }

        it { is_expected.to contain_exec('jenkins create-job myjob') }
        it { is_expected.to contain_exec('jenkins update-job myjob') }
        it { is_expected.not_to contain_exec('jenkins delete-job myjob') }
      end

      describe 'with job absent' do
        let(:params) { { ensure: 'absent', config: '' } }

        it { is_expected.not_to contain_exec('jenkins create-job myjob') }
        it { is_expected.not_to contain_exec('jenkins update-job myjob') }
        it { is_expected.to contain_exec('jenkins delete-job myjob') }
      end

      describe 'with replace false' do
        quotes = "<xml version='1.0' encoding='UTF-8'></xml>"
        let(:params) { { ensure: 'present', config: quotes, replace: false } }

        it { is_expected.to contain_exec('jenkins create-job myjob') }
        it { is_expected.not_to contain_exec('jenkins update-job myjob') }
        it { is_expected.not_to contain_exec('jenkins delete-job myjob') }
      end

      describe 'with an invalid $difftool' do
        let(:params) do
          {
            config: '',
            difftool: true
          }
        end

        it { is_expected.not_to compile }
      end

      describe 'with unformatted config' do
        unformatted_config = <<eos
<xml version='1.0' encoding='UTF-8'>
 <notselfclosing></notselfclosing>
 <notempty>...</notempty>
 <anotherempty></anotherempty>
 <quotes>&quot;...&quot;</quotes>
</xml>
eos
        formatted_config = <<eos
<xml version="1.0" encoding="UTF-8">
 <notselfclosing/>
 <notempty>...</notempty>
 <anotherempty/>
 <quotes>"..."</quotes>
</xml>
eos

        let(:params) do
          {
            ensure: 'present',
            config: unformatted_config
          }
        end

        it do
          is_expected.to contain_file('/tmp/myjob-config.xml').
            with_content(formatted_config)
        end
      end

      describe 'with config with single quotes' do
        quotes = "<xml version='1.0' encoding='UTF-8'></xml>"
        let(:params) { { ensure: 'present', config: quotes } }

        it do
          is_expected.to contain_file('/tmp/myjob-config.xml').
            with_content(%r{version="1\.0" encoding="UTF-8"})
        end
      end

      describe 'with config with empty tags' do
        empty_tags = '<xml><notempty><empty></empty></notempty><emptytwo></emptytwo></xml>'
        let(:params) { { ensure: 'present', config: empty_tags } }

        it do
          is_expected.to contain_file('/tmp/myjob-config.xml').
            with_content('<xml><notempty><empty/></notempty><emptytwo/></xml>')
        end
      end

      describe 'with config with &quot;' do
        quotes = '<config>the dog said &quot;woof&quot;</config>'
        let(:params) { { ensure: 'present', config: quotes } }

        it do
          is_expected.to contain_file('/tmp/myjob-config.xml').
            with_content('<config>the dog said "woof"</config>')
        end
      end

      describe 'with sourced config and blank regular config' do
        let(:thesource) { File.expand_path(File.dirname(__FILE__) + '/../fixtures/testjob.xml') }
        let(:params) { { ensure: 'present', source: thesource, config: '' } }

        it do
          is_expected.to contain_file('/tmp/myjob-config.xml').
            with_content(%r{sourcedconfig})
        end
      end

      describe 'with sourced config and regular config' do
        quotes = "<xml version='1.0' encoding='UTF-8'></xml>"
        let(:thesource) { File.expand_path(File.dirname(__FILE__) + '/../fixtures/testjob.xml') }
        let(:params) { { ensure: 'present', source: thesource, config: quotes } }

        it do
          is_expected.to contain_file('/tmp/myjob-config.xml').
            with_content(%r{sourcedconfig})
        end
      end

      describe 'with sourced config and no regular config' do
        let(:thesource) { File.expand_path(File.dirname(__FILE__) + '/../fixtures/testjob.xml') }
        let(:params) { { ensure: 'present', source: thesource } }

        it { is_expected.to raise_error(Puppet::Error, %r{(Must pass config|expects a value for parameter 'config')}) }
      end

      describe 'with templated config and blank regular config' do
        let(:thetemplate) { File.expand_path(File.dirname(__FILE__) + '/../fixtures/testjob.xml') }
        let(:params) { { ensure: 'present', template: thetemplate, config: '' } }

        it do
          is_expected.to contain_file('/tmp/myjob-config.xml').
            with_content(%r{sourcedconfig})
        end
      end

      describe 'with templated config and regular config' do
        quotes = "<xml version='1.0' encoding='UTF-8'></xml>"
        let(:thetemplate) { File.expand_path(File.dirname(__FILE__) + '/../fixtures/testjob.xml') }
        let(:params) { { ensure: 'present', template: thetemplate, config: quotes } }

        it do
          is_expected.to contain_file('/tmp/myjob-config.xml').
            with_content(%r{sourcedconfig})
        end
      end

      describe 'with templated config and no regular config' do
        let(:thetemplate) { File.expand_path(File.dirname(__FILE__) + '/../fixtures/testjob.xml') }
        let(:params) { { ensure: 'present', template: thetemplate } }

        it { is_expected.to raise_error(Puppet::Error, %r{(Must pass config|expects a value for parameter 'config')}) }
      end
    end
  end
end
