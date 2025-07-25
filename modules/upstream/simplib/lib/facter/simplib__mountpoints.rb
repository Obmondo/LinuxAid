# frozen_string_literal: true

#
# This fact provides information about select mountpoints that are of interest
# to other SIMP modules.
#
# The results are organized as a Hash with at least the following information.
# Information from the main `mountpoints` fact is used if found but corrected
# for bind mounts.
#
# All integer values in `mount_options` will be translated to `Integers`.
#
# HELPERS
#
# * Any item starting with `_` has been added in as a 'helper' for ease in use
#   inside of puppet code
#
# The following helpers are currently available:
#
#   * `_uid__user`  => User translation of the `uid` value
#   * `_gid__group` => Group translation of the `gid` value
#
#
# @example Standard output with a helper value
#
#   {
#     '/mountpoint' => {
#       'device'       => '/dev/something',
#       'filesystem'   => 'filesystem type',
#       'options'      => ['mount', 'options', 'gid=100'],
#       'options_hash' => {
#         'mount'       => nil,
#         'options'     => nil,
#         'gid'         => 100,
#         '_gid__group' => 'users'
#       }
#     }
#   }
#
require 'facter'

Facter.add('simplib__mountpoints') do
  confine kernel: :Linux
  confine { File.exist?('/proc/mounts') }

  setcode do
    target_dirs = ['/tmp', '/var/tmp', '/dev/shm', '/proc']

    # Holder of the multi-call content
    mount_list = {}

    facter_mountpoints = Facter.value('mountpoints') || {}

    # Sometimes Ruby has issues with /proc so fall back to a shell command
    Facter::Core::Execution.execute('cat /proc/mounts 2> /dev/null', on_fail: nil).each_line do |line|
      line.strip!

      next if line.empty? || line.match(%r{^\s+none\s+})

      dev, path, fs, opts, _junk = line.split(%r{\s+})

      next unless target_dirs.include?(path)

      path_settings = {
        'device' => dev,
        'filesystem' => fs,
        # Split on commas that are not in quotes
        'options' => opts.gsub(%r{'|"}, '').split(%r{,(?=(?:(?:[^'"]*(?:'|")){2})*[^'"]*$)}).map(&:strip),
      }

      if facter_mountpoints[path]
        mount_list[path] = facter_mountpoints[path]

        # The mountpoins fact does not capture all options correctly
        mount_list[path]['options'] = path_settings['options']
      else
        mount_list[path] = path_settings
      end
    end

    # Lookup table so we don't constantly lookup found UIDs and GIDs, etc...
    known_translations = {}

    # Check for bind mounts using findmnt since some systems (EL7) do not post the
    # 'bind' keyword into the mount options any longer.
    mount_list.each_key do |mnt|
      mount_list[mnt]['options'] ||= []

      unless mount_list[mnt]['options'].include?('bind')
        findmnt_output = Facter::Core::Execution.execute("findmnt #{mnt}", on_fail: nil)
        if findmnt_output
          mnt_source = findmnt_output.lines.last.split(%r{\s+})[1]

          # We're a bind mount if this happens
          if mnt_source.include?('[')
            bind_source = mnt_source[%r{\[(.*)\]}, 1] # Match contents in brackets, extract first match

            mount_list[mnt]['device'] = bind_source
            mount_list[mnt]['filesystem'] = 'none'
            mount_list[mnt]['options'] << 'bind'
          end
        end
      end

      # Add an 'options_hash' for easy processing
      # rubocop:disable Style/MultilineBlockChain
      mount_list[mnt]['options_hash'] = Hash[
        mount_list[mnt]['options'].map { |opt|
          # Split on options that are not in quotes
          opt.split(%r{=(?=(?:(?:[^'"]*(?:'|")){2})*[^'"]*$)}).map(&:strip)
        }.map do |opt_arr|
          if opt_arr[1] && opt_arr[1] =~ %r{\A\d+\Z}
            [opt_arr[0], opt_arr[1].to_i]
          else
            [opt_arr[0], opt_arr[1]]
          end
        end
      ]
      # rubocop:enable Style/MultilineBlockChain

      # Helper translation material
      if mount_list[mnt]['options_hash']['uid']
        require 'etc'

        begin
          known_translations[:uid] ||= {}

          found_uid = known_translations[:uid][mount_list[mnt]['options_hash']['uid']] || Etc.getpwuid(mount_list[mnt]['options_hash']['uid']).name
          mount_list[mnt]['options_hash']['_uid__user'] = found_uid

          known_translations[:uid][mount_list[mnt]['options_hash']['uid']] = found_uid
        rescue ArgumentError
          # noop
        end
      end

      next unless mount_list[mnt]['options_hash']['gid']

      begin
        require 'etc'

        known_translations[:gid] ||= {}

        found_gid = known_translations[:gid][mount_list[mnt]['options_hash']['gid']] || Etc.getgrgid(mount_list[mnt]['options_hash']['gid']).name
        mount_list[mnt]['options_hash']['_gid__group'] = found_gid

        known_translations[:gid][mount_list[mnt]['options_hash']['gid']] = found_gid
      rescue ArgumentError
        # noop
      end
    end

    mount_list
  end
end
