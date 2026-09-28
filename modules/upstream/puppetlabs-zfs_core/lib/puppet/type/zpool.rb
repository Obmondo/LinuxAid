# ZPool type
module Puppet
  # Puppet::Property
  class Property
    # VDev class
    class VDev < Property
      # @param array the array to be flattened and sorted
      # @return [Array] returns a flattened and sorted array
      def flatten_and_sort(array)
        array = [array] unless array.is_a? Array
        array.map { |a| a.split(' ') }.flatten.sort
      end

      # @param is the current state of the object
      # @return [Boolean] if the resource is in sync with what it should be
      def insync?(is)
        return @should == [:absent] if is == :absent

        flatten_and_sort(is) == flatten_and_sort(@should)
      end
    end

    # MultiVDev class
    class MultiVDev < VDev
      # @param is the current state of the object
      # @return [Boolean] if the resource is in sync with what it should be
      def insync?(is)
        return @should == [:absent] if is == :absent

        return false unless is.length == @should.length

        is.each_with_index { |list, i| return false unless flatten_and_sort(list) == flatten_and_sort(@should[i]) }

        # if we made it this far we are in sync
        true
      end
    end
  end

  Type.newtype(:zpool) do
    desc <<-DESC
  @summary Manage zpools. Create and delete zpools. The provider WILL NOT SYNC, only report differences.

  Supports vdevs with mirrors, raidz, logs, spares, and cache.

  @example Using zpool.
    zpool { 'tstpool':
      ensure => present,
      disk   => '/ztstpool/dsk',
    }
  DESC

    ensurable

    newproperty(:disk, array_matching: :all, parent: Puppet::Property::VDev) do
      desc 'The disk(s) for this pool. Can be an array or a space separated string.'
    end

    newproperty(:mirror, array_matching: :all, parent: Puppet::Property::MultiVDev) do
      desc "List of all the devices to mirror for this pool. Each mirror should be a
      space separated string:

          mirror => [\"disk1 disk2\", \"disk3 disk4\"],

      "

      validate do |value|
        raise ArgumentError, _('mirror names must be provided as string separated, not a comma-separated list') if value.include?(',')
      end
    end

    newproperty(:raidz, array_matching: :all, parent: Puppet::Property::MultiVDev) do
      desc "List of all the devices to raid for this pool. Should be an array of
      space separated strings:

          raidz => [\"disk1 disk2\", \"disk3 disk4\"],

      "

      validate do |value|
        raise ArgumentError, _('raid names must be provided as string separated, not a comma-separated list') if value.include?(',')
      end
    end

    newproperty(:spare, array_matching: :all, parent: Puppet::Property::VDev) do
      desc 'Spare disk(s) for this pool.'
    end

    newproperty(:log, array_matching: :all, parent: Puppet::Property::VDev) do
      desc 'Log disks for this pool. This type does not currently support mirroring of log disks.'
    end

    newproperty(:cache, array_matching: :all, parent: Puppet::Property::VDev) do
      desc 'Cache disks for this pool.'
    end

    newproperty(:ashift) do
      desc 'The Alignment Shift for the vdevs in the given pool.'

      validate do |_value|
        raise Puppet::Error _('This property is only supported on Linux') unless Facter.value(:kernel) == 'Linux'
      end
    end

    newproperty(:autoexpand) do
      desc 'The autoexpand setting for the given pool. Valid values are `on` or `off`'
    end

    newproperty(:failmode) do
      desc 'The failmode setting for the given pool. Valid values are `wait`, `continue` or `panic`'
    end

    newparam(:pool) do
      desc 'The name for this pool.'
      isnamevar
    end

    newparam(:raid_parity) do
      desc 'Determines parity when using the `raidz` parameter.'
    end

    validate do
      has_should = [:disk, :mirror, :raidz].select { |prop| should(prop) }
      raise _('You cannot specify %{multiple_props} on this type (only one)') % { multiple_props: has_should.join(' and ') } if has_should.length > 1
    end
  end
end
