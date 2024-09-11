# _Description_
#
# Returns a hash of sysctl values that are particularly relevant to SIMP
#
# We don't grab the entire output due to the sheer size of it
#
Facter.add("simplib_sysctl") do
  confine { Facter::Core::Execution.which('sysctl') }

  setcode do
    relevant_entries = [
      'crypto.fips_enabled',
      'kernel.ctrl-alt-del',
      'kernel.modules_disabled',
      'kernel.shmall',
      'kernel.shmmax',
      'kernel.shmmni',
      'kernel.tainted',
      'kernel.threads-max',
      'vm.swappiness'
    ]

    retval = {}

    relevant_entries.each do |entry|
      module_value = Facter::Core::Execution.exec("sysctl -n -e #{entry}")

      # we have observed this exec non-deterministically populate $? with
      # nil, although the exec succeeds.  This will happen with %x, ``, or
      # Facter.*.exec.
      #
      # For now we test around the issue by checking the output if $? is nil:
      if ($?.nil? && module_value) ||
          (!$?.nil? && $?.exitstatus.zero? && module_value && !module_value.strip.empty?)
      then
        module_value.strip!

        # These can be too big for facter to process as Integers
        unless entry.start_with?('kernel.shm')
          if module_value =~ /^\d+$/
            module_value = module_value.to_i
          end
        end

        retval[entry] = module_value
      end
    end

    retval
  end
end
