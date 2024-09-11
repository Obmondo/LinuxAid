#!/usr/bin/env rspec

require 'spec_helper'
provider_class = Puppet::Type.type(:kernel_parameter).provider(:grub2)

LENS = "Shellvars_list.lns"
FILTER = "*[label() =~ regexp('GRUB_CMDLINE_LINUX.*')]"

describe provider_class do
  it "should find grub2-mkconfig" do
    FileTest.stubs(:file?).returns false
    FileTest.stubs(:executable?).returns false
    FileTest.stubs(:file?).with('/usr/sbin/grub2-mkconfig').returns true
    FileTest.stubs(:executable?).with('/usr/sbin/grub2-mkconfig').returns true
    provider_class.mkconfig_path.should == '/usr/sbin/grub2-mkconfig'
  end

  it "should find grub-mkconfig" do
    FileTest.stubs(:file?).returns false
    FileTest.stubs(:executable?).returns false
    FileTest.stubs(:file?).with('/usr/sbin/grub-mkconfig').returns true
    FileTest.stubs(:executable?).with('/usr/sbin/grub-mkconfig').returns true
    provider_class.mkconfig_path.should == '/usr/sbin/grub-mkconfig'
  end
end

describe provider_class do
  before :each do
    Facter.clear
    Facter.stubs(:fact).with(:augeasprovider_grub_version).returns Facter.add(:augeasprovider_grub_version) { setcode { 2 } }

    provider_class.stubs(:default?).returns(true)
    FileTest.stubs(:exist?).returns false
    FileTest.stubs(:file?).returns false
    FileTest.stubs(:executable?).returns false
    [ '/usr/sbin/grub2-mkconfig', '/usr/sbin/grub-mkconfig' ].each do |path|
      FileTest.stubs(:file?).with(path).returns true
      FileTest.stubs(:exist?).with(path).returns true
      FileTest.stubs(:executable?).with(path).returns true
    end
    FileTest.stubs(:file?).with('/etc/grub2-efi.cfg').returns true
    FileTest.stubs(:file?).with('/boot/grub2/grub.cfg').returns true
    FileTest.stubs(:exist?).with('/etc/default/grub').returns true
  end

  context "with full file" do
    let(:tmptarget) { aug_fixture("full") }
    let(:target) { tmptarget.path }

    it "should list instances" do
      provider_class.stubs(:target).returns(target)
      inst = provider_class.instances.map { |p|
        {
          :name => p.get(:name),
          :ensure => p.get(:ensure),
          :value => p.get(:value),
          :bootmode => p.get(:bootmode),
        }
      }

      inst.size.should == 7
      inst[0].should == {:name=>"quiet", :ensure=>:present, :value=>:absent, :bootmode=>"all"}
      inst[1].should == {:name=>"elevator", :ensure=>:present, :value=>"noop", :bootmode=>"all"}
      inst[2].should == {:name=>"divider", :ensure=>:present, :value=>"10", :bootmode=>"all"}
      inst[3].should == {:name=>"rhgb", :ensure=>:present, :value=>:absent, :bootmode=>"default"}
      inst[4].should == {:name=>"nohz", :ensure=>:present, :value=>"on", :bootmode=>"default"}
      inst[5].should == {:name=>"rhgb", :ensure=>:present, :value=>:absent, :bootmode=>"normal"}
      inst[6].should == {:name=>"nohz", :ensure=>:present, :value=>"on", :bootmode=>"normal"}
    end

    describe "when creating entries" do
      before :each do
        provider_class.any_instance.expects(:mkconfig).with("-o", "/boot/grub2/grub.cfg")
        provider_class.any_instance.expects(:mkconfig).with("-o", "/etc/grub2-efi.cfg")
      end

      it "should create no-value entries" do
        apply!(Puppet::Type.type(:kernel_parameter).new(
          :name     => "foo",
          :ensure   => :present,
          :target   => target,
          :provider => "grub2"
        ))

        augparse_filter(target, LENS, FILTER, '
          { "GRUB_CMDLINE_LINUX"
            { "quote" = "\"" }
            { "value" = "quiet" }
            { "value" = "elevator=noop" }
            { "value" = "divider=10" }
            { "value" = "foo" }
          }
          { "GRUB_CMDLINE_LINUX_DEFAULT"
            { "quote" = "\"" }
            { "value" = "rhgb" }
            { "value" = "nohz=on" }
          }
        ')
      end

      it "should create entry with value" do
        apply!(Puppet::Type.type(:kernel_parameter).new(
          :name     => "foo",
          :ensure   => :present,
          :value    => "bar",
          :target   => target,
          :provider => "grub2"
        ))

        augparse_filter(target, LENS, FILTER, '
          { "GRUB_CMDLINE_LINUX"
            { "quote" = "\"" }
            { "value" = "quiet" }
            { "value" = "elevator=noop" }
            { "value" = "divider=10" }
            { "value" = "foo=bar" }
          }
          { "GRUB_CMDLINE_LINUX_DEFAULT"
            { "quote" = "\"" }
            { "value" = "rhgb" }
            { "value" = "nohz=on" }
          }
        ')
      end

      it "should create entries with multiple values" do
        apply!(Puppet::Type.type(:kernel_parameter).new(
          :name     => "foo",
          :ensure   => :present,
          :value    => ["bar", "baz"],
          :target   => target,
          :provider => "grub2"
        ))

        augparse_filter(target, LENS, FILTER, '
          { "GRUB_CMDLINE_LINUX"
            { "quote" = "\"" }
            { "value" = "quiet" }
            { "value" = "elevator=noop" }
            { "value" = "divider=10" }
            { "value" = "foo=bar" }
            { "value" = "foo=baz" }
          }
          { "GRUB_CMDLINE_LINUX_DEFAULT"
            { "quote" = "\"" }
            { "value" = "rhgb" }
            { "value" = "nohz=on" }
          }
        ')
      end

      it "should create normal boot-only entries" do
        apply!(Puppet::Type.type(:kernel_parameter).new(
          :name     => "foo",
          :ensure   => :present,
          :bootmode => :normal,
          :target   => target,
          :provider => "grub2"
        ))

        augparse_filter(target, LENS, FILTER, '
          { "GRUB_CMDLINE_LINUX"
            { "quote" = "\"" }
            { "value" = "quiet" }
            { "value" = "elevator=noop" }
            { "value" = "divider=10" }
          }
          { "GRUB_CMDLINE_LINUX_DEFAULT"
            { "quote" = "\"" }
            { "value" = "rhgb" }
            { "value" = "nohz=on" }
            { "value" = "foo" }
          }
        ')
      end

      it "should create default boot-only entries" do
        apply!(Puppet::Type.type(:kernel_parameter).new(
          :name     => "foo",
          :ensure   => :present,
          :bootmode => :default,
          :target   => target,
          :provider => "grub2"
        ))

        augparse_filter(target, LENS, FILTER, '
          { "GRUB_CMDLINE_LINUX"
            { "quote" = "\"" }
            { "value" = "quiet" }
            { "value" = "elevator=noop" }
            { "value" = "divider=10" }
          }
          { "GRUB_CMDLINE_LINUX_DEFAULT"
            { "quote" = "\"" }
            { "value" = "rhgb" }
            { "value" = "nohz=on" }
            { "value" = "foo" }
          }
        ')
      end
    end

    it "should error on recovery-only entries" do
      txn = apply(Puppet::Type.type(:kernel_parameter).new(
        :name     => "foo",
        :ensure   => :present,
        :bootmode => :recovery,
        :target   => target,
        :provider => "grub2"
      ))

      txn.any_failed?.should_not == nil
      @logs.first.level.should == :err
      @logs.first.message.include?("Unsupported bootmode").should == true
    end

    it "should delete entries" do
      provider_class.any_instance.expects(:mkconfig).with("-o", "/boot/grub2/grub.cfg")
      provider_class.any_instance.expects(:mkconfig).with("-o", "/etc/grub2-efi.cfg")

      apply!(Puppet::Type.type(:kernel_parameter).new(
        :name     => "divider",
        :ensure   => "absent",
        :target   => target,
        :provider => "grub2"
      ))

      augparse_filter(target, LENS, FILTER, '
        { "GRUB_CMDLINE_LINUX"
          { "quote" = "\"" }
          { "value" = "quiet" }
          { "value" = "elevator=noop" }
        }
        { "GRUB_CMDLINE_LINUX_DEFAULT"
          { "quote" = "\"" }
          { "value" = "rhgb" }
          { "value" = "nohz=on" }
        }
      ')
    end

    describe "when modifying values" do
      before :each do
        provider_class.any_instance.stubs(:create).never
      end

      it "should change existing values" do
        provider_class.any_instance.expects(:mkconfig).with("-o", "/boot/grub2/grub.cfg")
        provider_class.any_instance.expects(:mkconfig).with("-o", "/etc/grub2-efi.cfg")
        apply!(Puppet::Type.type(:kernel_parameter).new(
          :name     => "elevator",
          :ensure   => :present,
          :value    => "deadline",
          :target   => target,
          :provider => "grub2"
        ))

        augparse_filter(target, LENS, FILTER, '
          { "GRUB_CMDLINE_LINUX"
            { "quote" = "\"" }
            { "value" = "quiet" }
            { "value" = "elevator=deadline" }
            { "value" = "divider=10" }
          }
          { "GRUB_CMDLINE_LINUX_DEFAULT"
            { "quote" = "\"" }
            { "value" = "rhgb" }
            { "value" = "nohz=on" }
          }
        ')
      end

      it "should add value to entry" do
        provider_class.any_instance.expects(:mkconfig).with("-o", "/boot/grub2/grub.cfg")
        provider_class.any_instance.expects(:mkconfig).with("-o", "/etc/grub2-efi.cfg")
        apply!(Puppet::Type.type(:kernel_parameter).new(
          :name     => "quiet",
          :ensure   => :present,
          :value    => "foo",
          :target   => target,
          :provider => "grub2"
        ))

        augparse_filter(target, LENS, FILTER, '
          { "GRUB_CMDLINE_LINUX"
            { "quote" = "\"" }
            { "value" = "quiet=foo" }
            { "value" = "elevator=noop" }
            { "value" = "divider=10" }
          }
          { "GRUB_CMDLINE_LINUX_DEFAULT"
            { "quote" = "\"" }
            { "value" = "rhgb" }
            { "value" = "nohz=on" }
          }
        ')
      end

      it "should add and remove entries for multiple values" do
        provider_class.any_instance.expects(:mkconfig).with("-o", "/boot/grub2/grub.cfg").times(2)
        provider_class.any_instance.expects(:mkconfig).with("-o", "/etc/grub2-efi.cfg").times(2)

        # Add multiple entries
        apply!(Puppet::Type.type(:kernel_parameter).new(
          :name     => "elevator",
          :ensure   => :present,
          :value    => ["noop", "deadline"],
          :target   => target,
          :provider => "grub2"
        ))

        augparse_filter(target, LENS, FILTER, '
          { "GRUB_CMDLINE_LINUX"
            { "quote" = "\"" }
            { "value" = "quiet" }
            { "value" = "elevator=noop" }
            { "value" = "divider=10" }
            { "value" = "elevator=deadline" }
          }
          { "GRUB_CMDLINE_LINUX_DEFAULT"
            { "quote" = "\"" }
            { "value" = "rhgb" }
            { "value" = "nohz=on" }
          }
        ')

        # Remove one excess entry
        apply!(Puppet::Type.type(:kernel_parameter).new(
          :name     => "elevator",
          :ensure   => :present,
          :value    => ["deadline"],
          :target   => target,
          :provider => "grub2"
        ))

        augparse_filter(target, LENS, FILTER, '
          { "GRUB_CMDLINE_LINUX"
            { "quote" = "\"" }
            { "value" = "quiet" }
            { "value" = "elevator=deadline" }
            { "value" = "divider=10" }
          }
          { "GRUB_CMDLINE_LINUX_DEFAULT"
            { "quote" = "\"" }
            { "value" = "rhgb" }
            { "value" = "nohz=on" }
          }
        ')
      end
    end
  end

  context "with broken file" do
    let(:tmptarget) { aug_fixture("broken") }
    let(:target) { tmptarget.path }

    it "should fail to load" do
      txn = apply(Puppet::Type.type(:kernel_parameter).new(
        :name     => "foo",
        :ensure   => :present,
        :target   => target,
        :provider => "grub2"
      ))

      txn.any_failed?.should_not == nil
      @logs.first.level.should == :err
      @logs.first.message.include?(target).should == true
    end
  end
end
