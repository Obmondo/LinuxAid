require 'spec_helper'
require 'shared_behaviours/all_parsedfile_providers'

# TODO: We've recently dropped running specs on Solaris because it was poor ROI.
# This file has a ton of tiptoeing around Solaris that we should ultimately
# remove, but I don't want to do so just yet, in case we get pushback to
# restore Solaris spec tests.

describe Puppet::Type.type(:mount).provider(:parsed), unless: Puppet.features.microsoft_windows? do
  before :each do
    Facter.clear
  end

  let :vfstab_sample do
    "/dev/dsk/c0d0s0 /dev/rdsk/c0d0s0 \t\t    /  \t    ufs     1 no\t-"
  end

  let :fstab_sample do
    "/dev/vg00/lv01\t/spare   \t  \t   ext3    defaults\t1 2"
  end

  # LAK:FIXME I can't mock Facter because this test happens at parse-time.
  it 'defaults to /etc/vfstab on Solaris' do
    if Facter.value(:osfamily) != 'Solaris'
      skip('This test only works on Solaris')
    else
      expect(described_class.default_target).to eq('/etc/vfstab')
    end
  end

  it 'defaults to /etc/filesystems on AIX' do
    pending 'This test only works on AIX' unless Facter.value(:osfamily) == 'AIX'
    expect(described_class.default_target).to eq('/etc/filesystems')
  end

  it 'defaults to /etc/fstab on anything else' do
    if Facter.value(:osfamily) == 'Solaris'
      skip('This test only does not work on Solaris')
    else
      expect(described_class.default_target).to eq('/etc/fstab')
    end
  end

  describe 'when parsing a line' do
    it 'does not crash on incomplete lines in fstab' do
      parse = described_class.parse <<-FSTAB
/dev/incomplete
/dev/device       name
FSTAB
      expect { described_class.to_line(parse[0]) }.not_to raise_error
    end

    #   it_should_behave_like "all parsedfile providers",
    #     provider_class, my_fixtures('*.fstab')

    describe 'on Solaris', if: Facter.value(:osfamily) == 'Solaris' do
      it 'extracts device from the first field' do
        expect(described_class.parse_line(vfstab_sample)[:device]).to eq('/dev/dsk/c0d0s0')
      end

      it 'extracts blockdevice from second field' do
        expect(described_class.parse_line(vfstab_sample)[:blockdevice]).to eq('/dev/rdsk/c0d0s0')
      end

      it 'extracts name from third field' do
        expect(described_class.parse_line(vfstab_sample)[:name]).to eq('/')
      end

      it 'extracts fstype from fourth field' do
        expect(described_class.parse_line(vfstab_sample)[:fstype]).to eq('ufs')
      end

      it 'extracts pass from fifth field' do
        expect(described_class.parse_line(vfstab_sample)[:pass]).to eq('1')
      end

      it 'extracts atboot from sixth field' do
        expect(described_class.parse_line(vfstab_sample)[:atboot]).to eq('no')
      end

      it 'extracts options from seventh field' do
        expect(described_class.parse_line(vfstab_sample)[:options]).to eq('-')
      end
    end

    describe 'on other platforms than Solaris', if: Facter.value(:osfamily) != 'Solaris' do
      it 'extracts device from the first field' do
        expect(described_class.parse_line(fstab_sample)[:device]).to eq('/dev/vg00/lv01')
      end

      it 'extracts name from second field' do
        expect(described_class.parse_line(fstab_sample)[:name]).to eq('/spare')
      end

      it 'extracts fstype from third field' do
        expect(described_class.parse_line(fstab_sample)[:fstype]).to eq('ext3')
      end

      it 'extracts options from fourth field' do
        expect(described_class.parse_line(fstab_sample)[:options]).to eq('defaults')
      end

      it 'extracts dump from fifth field' do
        expect(described_class.parse_line(fstab_sample)[:dump]).to eq('1')
      end

      it 'extracts options from sixth field' do
        expect(described_class.parse_line(fstab_sample)[:pass]).to eq('2')
      end
    end
  end

  describe 'mountinstances' do
    it 'gets name from mountoutput found on Solaris' do
      Facter.stubs(:value).with(:osfamily).returns 'Solaris'
      described_class.stubs(:mountcmd).returns(File.read(my_fixture('solaris.mount')))
      mounts = described_class.mountinstances
      expect(mounts.size).to eq(6)
      expect(mounts[0]).to eq(name: '/', mounted: :yes)
      expect(mounts[1]).to eq(name: '/proc', mounted: :yes)
      expect(mounts[2]).to eq(name: '/etc/mnttab', mounted: :yes)
      expect(mounts[3]).to eq(name: '/tmp', mounted: :yes)
      expect(mounts[4]).to eq(name: '/export/home', mounted: :yes)
      expect(mounts[5]).to eq(name: '/ghost', mounted: :yes)
    end

    it 'gets name from mountoutput found on HP-UX' do
      Facter.stubs(:value).with(:osfamily).returns 'HP-UX'
      described_class.stubs(:mountcmd).returns(File.read(my_fixture('hpux.mount')))
      mounts = described_class.mountinstances
      expect(mounts.size).to eq(17)
      expect(mounts[0]).to eq(name: '/', mounted: :yes)
      expect(mounts[1]).to eq(name: '/devices', mounted: :yes)
      expect(mounts[2]).to eq(name: '/dev', mounted: :yes)
      expect(mounts[3]).to eq(name: '/system/contract', mounted: :yes)
      expect(mounts[4]).to eq(name: '/proc', mounted: :yes)
      expect(mounts[5]).to eq(name: '/etc/mnttab', mounted: :yes)
      expect(mounts[6]).to eq(name: '/etc/svc/volatile', mounted: :yes)
      expect(mounts[7]).to eq(name: '/system/object', mounted: :yes)
      expect(mounts[8]).to eq(name: '/etc/dfs/sharetab', mounted: :yes)
      expect(mounts[9]).to eq(name: '/lib/libc.so.1', mounted: :yes)
      expect(mounts[10]).to eq(name: '/dev/fd', mounted: :yes)
      expect(mounts[11]).to eq(name: '/tmp', mounted: :yes)
      expect(mounts[12]).to eq(name: '/var/run', mounted: :yes)
      expect(mounts[13]).to eq(name: '/export', mounted: :yes)
      expect(mounts[14]).to eq(name: '/export/home', mounted: :yes)
      expect(mounts[15]).to eq(name: '/rpool', mounted: :yes)
      expect(mounts[16]).to eq(name: '/ghost', mounted: :yes)
    end

    it 'gets name from mountoutput found on Darwin' do
      Facter.stubs(:value).with(:osfamily).returns 'Darwin'
      described_class.stubs(:mountcmd).returns(File.read(my_fixture('darwin.mount')))
      mounts = described_class.mountinstances
      expect(mounts.size).to eq(6)
      expect(mounts[0]).to eq(name: '/', mounted: :yes)
      expect(mounts[1]).to eq(name: '/dev', mounted: :yes)
      expect(mounts[2]).to eq(name: '/net', mounted: :yes)
      expect(mounts[3]).to eq(name: '/home', mounted: :yes)
      expect(mounts[4]).to eq(name: '/usr', mounted: :yes)
      expect(mounts[5]).to eq(name: '/ghost', mounted: :yes)
    end

    it 'gets name from mountoutput found on Linux' do
      Facter.stubs(:value).with(:osfamily).returns 'Gentoo'
      described_class.stubs(:mountcmd).returns(File.read(my_fixture('linux.mount')))
      mounts = described_class.mountinstances
      expect(mounts[0]).to eq(name: '/', mounted: :yes)
      expect(mounts[1]).to eq(name: '/lib64/rc/init.d', mounted: :yes)
      expect(mounts[2]).to eq(name: '/sys', mounted: :yes)
      expect(mounts[3]).to eq(name: '/usr/portage', mounted: :yes)
      expect(mounts[4]).to eq(name: '/ghost', mounted: :yes)
      expect(mounts[5]).to eq(name: '/run', mounted: :yes)
    end

    it 'gets name from mountoutput found on AIX' do
      Facter.stubs(:value).with(:osfamily).returns 'AIX'
      described_class.stubs(:mountcmd).returns(File.read(my_fixture('aix.mount')))
      mounts = described_class.mountinstances
      expect(mounts[0]).to eq(name: '/', mounted: :yes)
      expect(mounts[1]).to eq(name: '/usr', mounted: :yes)
      expect(mounts[2]).to eq(name: '/var', mounted: :yes)
      expect(mounts[3]).to eq(name: '/tmp', mounted: :yes)
      expect(mounts[4]).to eq(name: '/home', mounted: :yes)
      expect(mounts[5]).to eq(name: '/admin', mounted: :yes)
      expect(mounts[6]).to eq(name: '/proc', mounted: :yes)
      expect(mounts[7]).to eq(name: '/opt', mounted: :yes)
      expect(mounts[8]).to eq(name: '/srv/aix', mounted: :yes)
    end

    it 'raises an error if a line is not understandable' do
      described_class.stubs(:mountcmd).returns('bazinga!')
      expect { described_class.mountinstances }.to raise_error Puppet::Error, 'Could not understand line bazinga! from mount output'
    end
  end

  it "supports AIX's paragraph based /etc/filesystems" do
    pending 'This test only works on AIX' unless Facter.value(:osfamily) == 'AIX'
    Facter.stubs(:value).with(:osfamily).returns 'AIX'
    described_class.stubs(:default_target).returns my_fixture('aix.filesystems')
    described_class.stubs(:mountcmd).returns File.read(my_fixture('aix.mount'))
    instances = described_class.instances
    expect(instances[0].name).to eq('/')
    expect(instances[0].device).to eq('/dev/hd4')
    expect(instances[0].fstype).to eq('jfs2')
    expect(instances[0].options).to eq('check=false,free=true,log=NULL,mount=automatic,quota=no,type=bootfs,vol=root')
    expect(instances[11].name).to eq('/srv/aix')
    expect(instances[11].device).to eq('mynode')
    expect(instances[11].fstype).to eq('nfs')
    expect(instances[11].options).to eq('vers=2,account=false,log=NULL,mount=true')
  end

  my_fixtures('*.fstab').each do |fstab|
    platform = File.basename(fstab, '.fstab')

    describe "when calling instances on #{platform}" do
      let(:instances) do
        described_class.instances.map { |prov| { name: prov.get(:name), ensure: prov.get(:ensure) } }
      end

      before :each do
        if Facter[:osfamily] == 'Solaris'
          platform == 'solaris' ||
            skip("We need to stub the operatingsystem fact at load time, but can't")
        else
          platform != 'solaris' ||
            skip("We need to stub the operatingsystem fact at load time, but can't")
        end

        # Stub the mount output to our fixture.
        begin
          mount = my_fixture(platform + '.mount')
          described_class.stubs(:mountcmd).returns File.read(mount)
        rescue
          skip "is #{platform}.mount missing at this point?"
        end

        # Note: we have to stub default_target before creating resources
        # because it is used by Puppet::Type::Mount.new to populate the
        # :target property.
        described_class.stubs(:default_target).returns fstab
      end

      # Following mountpoint are present in all fstabs/mountoutputs
      describe 'on other platforms than Solaris', if: Facter.value(:osfamily) != 'Solaris' do
        it 'includes unmounted resources' do
          expect(instances).to include(name: '/', ensure: :mounted)
        end

        it 'includes mounted resources' do
          expect(instances).to include(name: '/boot', ensure: :unmounted)
        end

        it 'includes ghost resources' do
          expect(instances).to include(name: '/ghost', ensure: :ghost)
        end
      end
    end

    describe "when prefetching on #{platform}" do
      let(:res_ghost) { Puppet::Type::Mount.new(name: '/ghost') }  # in no fake fstab
      let(:res_mounted) { Puppet::Type::Mount.new(name: '/') }     # in every fake fstab
      let(:res_unmounted) { Puppet::Type::Mount.new(name: '/boot') } # in every fake fstab
      let(:res_absent) { Puppet::Type::Mount.new(name: '/absent') } # in no fake fstab
      let(:res_trailing_slash) { Puppet::Type::Mount.new(name: '/run/') } # in Linux fake fstab
      let(:resource_hash) do
        # Simulate transaction.rb:prefetch
        hash = {}
        [res_ghost, res_mounted, res_unmounted, res_absent, res_trailing_slash].each do |resource|
          hash[resource.name] = resource
        end
        hash
      end

      before :each do
        if Facter[:osfamily] == 'Solaris'
          platform == 'solaris' ||
            skip("We need to stub the operatingsystem fact at load time, but can't")
        else
          platform != 'solaris' ||
            skip("We need to stub the operatingsystem fact at load time, but can't")
        end

        # Stub the mount output to our fixture.
        begin
          mount = my_fixture(platform + '.mount')
          described_class.stubs(:mountcmd).returns File.read(mount)
        rescue
          skip "is #{platform}.mount missing at this point?"
        end

        # Note: we have to stub default_target before creating resources
        # because it is used by Puppet::Type::Mount.new to populate the
        # :target property.
        described_class.stubs(:default_target).returns fstab
      end

      describe 'on other platforms than Solaris', if: Facter.value(:osfamily) != 'Solaris' do
        it 'sets :ensure to :unmounted if found in fstab but not mounted' do
          described_class.prefetch(resource_hash)
          expect(res_unmounted.provider.get(:ensure)).to eq(:unmounted)
        end

        it 'sets :ensure to :ghost if not found in fstab but mounted' do
          described_class.prefetch(resource_hash)
          expect(res_ghost.provider.get(:ensure)).to eq(:ghost)
        end

        it 'sets :ensure to :mounted if found in fstab and mounted' do
          described_class.prefetch(resource_hash)
          expect(res_mounted.provider.get(:ensure)).to eq(:mounted)
        end

        it 'strips trailing slashes from resource titles' do
          described_class.prefetch(resource_hash)
          expect(res_trailing_slash.provider.get(:ensure)).to eq(:mounted)
        end
      end

      it 'sets :ensure to :absent if not found in fstab and not mounted' do
        described_class.prefetch(resource_hash)
        expect(res_absent.provider.get(:ensure)).to eq(:absent)
      end
    end
  end
end
