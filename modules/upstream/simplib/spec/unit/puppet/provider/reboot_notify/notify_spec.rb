require 'spec_helper'

describe Puppet::Type.type(:reboot_notify).provider(:notify) do
  let(:resource) {
    Puppet::Type.type(:reboot_notify).new(
      name: 'Foo',
      reason: 'Bar'
    )
  }
  let(:provider) {
    Puppet::Type.type(:reboot_notify).provider(:notify).new(resource)
  }

  before(:each) do
    @catalog = Puppet::Resource::Catalog.new
    Puppet::Type::Reboot_notify.any_instance.stubs(:catalog).returns(@catalog)

    @tmpdir = Dir.mktmpdir('rspec_reboot_notify')
    @target = File.join(@tmpdir, 'reboot_notifications.json')
    Puppet.stubs(:[]).with(:vardir).returns @tmpdir
  end

  after(:each) do
    FileUtils.remove_dir(@tmpdir) if File.exist?(@tmpdir)
  end

  context '#exists?' do
    it 'does not exist' do
      expect(provider.exists?).to be_falsey
    end

    context 'does exist' do
      it 'is empty' do
        FileUtils.touch(@target)

        expect(provider.exists?).to be_falsey
      end

      it 'is invalid' do
        File.open(@target, 'w'){|fh| fh.puts('{')}

        expect(provider.exists?).to be_falsey
      end

      it 'is empty json' do
        File.open(@target, 'w'){|fh| fh.puts('{}')}

        expect(provider.exists?).to be_truthy
      end

      it 'only contains metadata' do
        File.open(@target, 'w') do |fh|
          fh.puts <<-EOM
          {
            "reboot_control_metadata": {
              "log_level": "notice"
            }
          }
          EOM
        end

        expect(provider.exists?).to be_truthy
      end

      context 'has a matching record' do
        it 'is in sync' do
          File.open(@target, 'w') do |fh|
            fh.puts <<-EOM
            {
              "reboot_control_metadata": {
                "log_level": "notice"
              },
              "Foo": {
                "reason": "Bar",
                "updated": "0000000"
              }
            }
            EOM
          end

          expect(provider.exists?).to be_truthy
        end

        it 'is out of sync' do
          File.open(@target, 'w') do |fh|
            fh.puts <<-EOM
            {
              "reboot_control_metadata": {
                "log_level": "notice"
              },
              "Foo": {
                "reason": "Nope",
                "updated": "0000000"
              }
            }
            EOM
          end

          expect(provider.exists?).to be_falsey
        end
      end
    end
  end

  context '#create' do
    it 'should create a valid JSON file' do
      content = nil

      expect{
        provider.create
        content = JSON.parse(File.read(@target))
      }.to_not raise_error

      expect(
        content['reboot_control_metadata']
      ).to eq({ 'log_level' => 'notice' })

      expect( content['Foo'] ).to_not be_nil
      expect( content['Foo']['reason'] ).to eq('Bar')
    end

    context 'the target directory does not exist' do
      it do
        FileUtils.remove_dir(@tmpdir) if File.exist?(@tmpdir)

        expect{ provider.create }.to raise_error(/Could not create.*#{@target}/)
      end
    end
  end

  context '#destroy' do
    it 'should remove the target file' do
      expect{ provider.destroy }.to_not raise_error

      expect(File.exist?(@target)).to be_falsey
    end

    context 'the target has been removed' do
      it do
        FileUtils.rm_f(@target)

        expect{ provider.destroy }.to_not raise_error
      end
    end
  end

  context '#update' do
    it 'should update the file with the new content' do
      expect{ provider.update }.to_not raise_error

      output = JSON.parse(File.read(@target))

      expect(output.keys).to include('Foo')
      expect(output['Foo']['reason']).to eq('Bar')
      expect(output['Foo']['updated']).to be_a(Integer)
    end

    it 'should not erase existing content' do

      orig_data = {
        'PreExisting' => {
          'reason' => 'Condition',
          'updated' => 12345
        }
      }

      File.open(@target, 'w'){|fh| fh.puts(JSON.pretty_generate(orig_data))}

      # This populates the record content
      expect{ provider.exists?}.to_not raise_error
      expect{ provider.update }.to_not raise_error

      output = JSON.parse(File.read(@target))

      expect(output.keys).to include('PreExisting')
      expect(output['PreExisting']).to eq(orig_data['PreExisting'])

      expect(output.keys).to include('Foo')
      expect(output['Foo']['reason']).to eq('Bar')
      expect(output['Foo']['updated']).to be_a(Integer)
    end

    context 'the target has been removed' do
      it do
        FileUtils.remove_dir(@tmpdir) if File.exist?(@tmpdir)

        expect{ provider.update}.to raise_error(/Could not update.*#{@target}/)
      end
    end

    context 'control_only is set' do
      let(:resource) {
        Puppet::Type.type(:reboot_notify).new(
          name: 'Foo',
          reason: 'Bar',
          control_only: true
        )
      }

      it do
        expect{ provider.update }.to_not raise_error
        expect(
          JSON.parse(File.read(@target))
        ).to eq({'reboot_control_metadata' => { 'log_level' => 'notice' }})
      end

      [:alert, :crit, :debug, :notice, :emerg, :err, :info, :warning].each do |log_level|
        context "log_level is #{log_level}" do
          let(:resource) {
            Puppet::Type.type(:reboot_notify).new(
              name: 'Foo',
              reason: 'Bar',
              control_only: true,
              log_level: log_level.to_s
            )
          }

          it do
            # This should always be prevented by the Type but is here in case
            # of a regression in Puppet or a bad update to the type.
            Puppet.expects(:warning).with(
              regexp_matches(/Invalid log_level:/)
            ).never
            Puppet.expects(log_level).with(
              regexp_matches(/System Reboot Required Because:/)
            ).at_most_once

            expect{ provider.update }.to_not raise_error
            expect(
              JSON.parse(File.read(@target))
            ).to eq({'reboot_control_metadata' => { 'log_level' => log_level.to_s }})
          end
        end
      end
    end
  end

  context '#self.post_resource_eval' do
    before(:each) do
      expect{ provider.exists?}.to_not raise_error
      expect{ provider.update }.to_not raise_error
    end

    let(:output) { JSON.parse(File.read(@target)) }

    it do
      Puppet.expects(:notice).with(
        regexp_matches(/System Reboot Required Because:/)
      ).at_most_once

      expect{ provider.class.post_resource_eval }.to_not raise_error
    end

    context 'the target has invalid json' do
      it 'should fail' do
        File.open(@target, 'w'){|fh| fh.puts('{')}

        expect{ provider.class.post_resource_eval }.to raise_error(/Invalid JSON in '#{@target}'/)
      end
    end

    context 'the target has been removed' do
      it do
        FileUtils.remove_dir(@tmpdir) if File.exist?(@tmpdir)

        expect{ provider.class.post_resource_eval }.to raise_error(/Could not read file '#{@target}'/)
      end
    end

    context 'with records to be expired' do
      let(:data) {{
        'ToDelete' => {
          'reason' => 'Old',
          'updated' => 12345
        },
        'ToKeep' => {
          'reason' => 'New',
          'updated' => Time.now.tv_sec
        }
      }}

      it 'should expire old records' do
        File.open(@target, 'w'){|fh| fh.puts(JSON.pretty_generate(data))}

        expect{ provider.class.post_resource_eval}.to_not raise_error

        updates = JSON.parse(File.read(@target))

        expect(updates.keys).to_not include('ToDelete')
        expect(updates.keys).to include('ToKeep')
        expect(updates['ToKeep']).to eq(data['ToKeep'])
      end
    end

    context 'log_level is set' do
      let(:resource) {
        Puppet::Type.type(:reboot_notify).new(
          name: 'Foo',
          reason: 'Bar',
          log_level: 'debug'
        )
      }

      it do
        expect{ provider.update }.to_not raise_error
        Puppet.expects(:debug).with(
          regexp_matches(/System Reboot Required Because:/)
        ).at_most_once
        expect{ provider.class.post_resource_eval}.to_not raise_error

        content = JSON.parse(File.read(@target))

        expect(content.keys).to include('Foo')
      end
    end
  end
end
