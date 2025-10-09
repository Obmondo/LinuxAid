# Merge two sets of `mount` options in a reasonable fashion, giving
# precedence to the second set.
Puppet::Functions.create_function(:'simplib::join_mount_opts') do
  # @param system_mount_opts System mount options
  # @param new_mount_opts  New mount options, which will override
  #   `system_mount_opts` when there are conflicts
  # @return [String] Merged options string in which `new_mount_opts`
  #   mount options take precedence; options are comma delimited
  #
  dispatch :join_mount_opts do
    required_param 'Array[String]', :system_mount_opts
    required_param 'Array[String]', :new_mount_opts
  end

  def join_mount_opts(system_mount_opts, new_mount_opts)
    system_opts = system_mount_opts.map(&:strip)
    new_opts = new_mount_opts.map(&:strip)

    # Remove any items that have a corresponding 'no' item in the
    # list. Such as 'dev' vs 'nodev', etc...
    system_opts.delete_if do |x|
      new_opts.include?("no#{x}")
    end
    # Reverse this if the user wants to explicitly set an option and a no*
    # option is already present.
    system_opts.delete_if do |x|
      found = false
      if x =~ %r{^no(.*)}
        found = new_opts.include?(Regexp.last_match(1))
      end

      found
    end

    mount_options = {}
    scope = closure_scope
    selinux_current_mode = scope['facts'].dig('os', 'selinux', 'current_mode')

    if !selinux_current_mode || (selinux_current_mode == 'disabled')
      # SELinux is off, get rid of selinux related items in the options
      system_opts.delete_if { |x| x =~ %r{^(((fs|def|root)?context=)|seclabel)} }
      new_opts.delete_if { |x| x =~ %r{^(((fs|def|root)?context=)|seclabel)} }
    elsif system_opts.include?('seclabel')
      # Remove any SELinux context items if 'seclabel' is set. This
      # means that we can't remount it with new options.
      system_opts.delete_if { |x| x =~ %r{^(fs|def|root)?context=} }
      new_opts.delete_if { |x| x =~ %r{^(fs|def|root)?context=} }
      # These two aren't compatible for remounts and can cause
      # issues unless done *very* carefully.
    end

    (system_opts + new_opts).each do |opt|
      k, v = opt.split('=')
      if v&.include?('"\'') # special case with "' that will cause problems
        v.delete!('"\'')
        # Anything with a comma must be double quoted!
        v = '"' + v + '"' if v.include?(',')
      end
      mount_options[k] = v
    end

    retval = mount_options.keys.sort.map do |k|
      if mount_options[k]
        "#{k}=#{mount_options[k]}"
      else
        k
      end
    end

    retval.join(',')
  end
end
