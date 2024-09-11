module PuppetX
  module AugeasprovidersGrub
    module Util
      # Return a merge of the system options and the new options.
      #
      # The following format is supported for the new options
      # ':defaults:'  => Copy defaults from the default GRUB entry
      # ':preserve:'  => Preserve all existing options (if present)
      #
      # ':defaults:' and ':preserve:' are mutually exclusive!
      #
      # All of the options below supersede any items affected by the above
      #
      # 'entry(=.*)?' => Ensure that `entry` exists *as entered*; replaces all
      #                  other options with the same name
      # '!entry(=.*)? => Add this option to the end of the arguments,
      #                  preserving any other options of the same name
      # '-:entry'     => Ensure that all instances of `entry` do not exist
      # '-:entry=foo' => Ensure that only instances of `entry` with value `foo` do not exist
      #
      # @param system_opts [Array] the current system options for this entry
      # @param new_opts [Array] the new options for this entry
      # @param default_opts [Array] the default entry options (if applicable)
      # @return [Array] a merged/manipulated array of options
      def self.munge_options(system_opts, new_opts, default_opts=[])
        sys_opts = Array(system_opts).flatten.map(&:strip)
        opts     = Array(new_opts).flatten.map(&:strip)
        def_opts = Array(default_opts).flatten.map(&:strip)

        result_opts = []
        result_opts = def_opts.dup if opts.delete(':defaults:')

        if opts.delete(':preserve:')
          # Need to remove any result opts that are being preserved
          sys_opts_keys = sys_opts.map{|x| x = x.split('=').first.strip}

          result_opts.delete_if do |x|
            key = x.split('=').first.strip

            sys_opts_keys.include?(key)
          end

          result_opts += sys_opts
        end

        # Get rid of everything with a '-:'
        discards = Array(opts.select{|x| x =~ /^-:/}.map{|x| x = x[2..-1]})
        opts.delete_if{|x| x =~ /^-:/}

        result_opts.delete_if{|x|
          discards.index{|d|
            ( d == x ) || ( d == x.split('=').first )
          }
        }

        # Prepare to append everything with a '!:'
        appends = Array(opts.select{|x| x =~ /^!:/}.map{|x| x = x[2..-1]})
        opts.delete_if{|x| x =~ /^!:/}

        # We only want to append items that aren't in the list already
        appends.delete_if{|x| result_opts.include?(x)}

        # Replace these items in place if possible
        tmp_results = []
        new_results = []

        opts.each do |opt|
          key = opt.split('=').first

          old_entry = result_opts.index{|x| x.split('=').first == key}

          if old_entry
            # Replace the first instance of a given item with the matching option.
            tmp_results[old_entry] = opt
            result_opts.map!{|x| x = (x.split('=').first == key) ? nil : x}
          else
            # Keep track of everything that we aren't replacing
            new_results << opt
          end
        end

        # Copy in all of the remaining options in place
        result_opts.each_index do |i|
          if result_opts[i]
            tmp_results[i] = result_opts[i]
          end
        end

        # Ensure that we're not duplicating arguments
        return (tmp_results.compact + new_results + appends).
          flatten.
          join(' ').
          scan(/\S+=(?:(?:".+?")|(?:\S+))|\S+/).
          uniq
      end

      # Take care of copying ':default:' values and ensure that the leading
      # 'boot' entries are stripped off of passed entries.
      #
      # @value (String) The value to munge
      # @flavor (String) The section in the 'grubby' output to use (kernel, initrd, etc...)
      # @grubby_info (Hash) The broken down output of 'grubby' into a Hash
      # @returns (String) The cleaned value
      def self.munge_grubby_value(value, flavor, grubby_info)
        if value == ':default:'
          if grubby_info.empty? || !grubby_info[flavor]
            raise Puppet::Error, "No default GRUB information found for `#{flavor}`"
          end

          value = grubby_info[flavor]

          # In some cases, /boot gets shoved on by GRUB and we can't compare againt
          # that.
          value = value.split('/')
          if value[1] == 'boot'
            value.delete_at(1)
          end

          value = value.join('/')
        end

        return value
      end

      # Return the location of the GRUB2 configuration on the system.
      # Raise an error if not found.
      #
      # @return (String) The full path to the GRUB2 configuration file.
      def self.grub2_cfg_path
        paths = [
          '/etc/grub2.cfg',
          '/boot/grub/grub.cfg',
          '/boot/grub2/grub.cfg'
        ]

        if File.exist?('/sys/firmware/efi')
          os_info = Facter.value(:os)
          if os_info
            os_name = Facter.value(:os)['name']
          else
            # Support for old versions of Facter
            unless os_name
              os_name = Facter.value(:operatingsystem)
            end
          end

          paths = [
            '/etc/grub2-efi.cfg',
            # Handle the standard EFI naming convention
            "/boot/efi/EFI/#{os_name.downcase}/grub.cfg"
          ] + paths
        end

        paths.each do |path|
          return path if (File.readable?(path) && !File.directory?(path))
        end

        raise Puppet::Error, 'Could not find a GRUB2 configuration on the system'
      end

      # Return the contents of the GRUB2 configuration on the system.
      # Raise an error if not found.
      #
      # @return (String) The contents of the GRUB2 configuration on the system.
      def self.grub2_cfg
        return File.read(grub2_cfg_path)
      end

      # Return a list of options that have the kernel path prepended and are
      # formatted with all processing arguments handled.
      #
      # @param old_opts (Array[String]) An array of all old options
      # @param new_opts (Array[String]) An array of all new options
      # @param default_kernel (String) The default kernel
      # @param default_kernel_opts (Array[String]) The default kernel options
      # @param prepend_kernel_path (Boolean) If true, add the kernel itself to the default kernel options
      # @return (Array[String]) An Array of processed options
      def self.munged_options(old_opts, new_opts, default_kernel, default_kernel_opts, prepend_kernel_path=false)
        # You need to prepend the kernel path for the defaults if you're trying to
        # format for `module` lines.

        default_kernel_opts = Array(default_kernel_opts)

        if default_kernel && prepend_kernel_path
          default_kernel_opts = Array(default_kernel) + default_kernel_opts
        end

        return munge_options(old_opts, new_opts, default_kernel_opts)
      end
    end
  end
end
