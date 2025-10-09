# frozen_string_literal: true

Puppet::Type.type(:posix_acl).provide(:posixacl, parent: Puppet::Provider) do
  desc 'Provide posix 1e acl functions using posix getfacl/setfacl commands'

  if Facter.value(:operatingsystem) == 'Gentoo'
    commands setfacl: '/bin/setfacl'
    commands getfacl: '/bin/getfacl'
  else
    commands setfacl: '/usr/bin/setfacl'
    commands getfacl: '/usr/bin/getfacl'
  end

  confine feature: :posix
  defaultfor osfamily: %i[debian redhat suse gentoo]

  def exists?
    permission
  end

  def unset_perm(perm, path)
    # Don't try to unset mode bits, it doesn't make sense!
    return if perm =~ %r{^(((u(ser)?)|(g(roup)?)|(m(ask)?)|(o(ther)?)):):}

    perm = perm.split(':')[0..-2].join(':')
    if check_recursive
      setfacl('-R', '-n', '-x', perm, path)
    else
      setfacl('-n', '-x', perm, path)
    end
  end

  def set_perm(perm_set, path)
    args_list = ['-n']
    args_list << '-R' if check_recursive
    perm_set.each do |perm|
      args_list << '-m'
      args_list << perm
    end
    args_list << path
    setfacl(args_list)
  end

  def unset
    @resource.value(:permission).each do |perm|
      unset_perm(perm, @resource.value(:path))
    end
  end

  def purge
    if check_recursive
      setfacl('-R', '-b', @resource.value(:path))
    else
      setfacl('-b', @resource.value(:path))
    end
  end

  def permission
    return ['DOES_NOT_EXIST'] unless File.exist?(@resource.value(:path))

    value = []
    # String#lines would be nice, but we need to support Ruby 1.8.5
    getfacl('--absolute-names', '--no-effective', @resource.value(:path)).split("\n").each do |line|
      # Strip comments and blank lines
      value << line.gsub('\040', ' ') if line !~ %r{^#} && line != ''
    end
    value.sort
  end

  def check_recursive
    # Changed functionality to return boolean true or false
    @resource.value(:recursive) == :true && resource.value(:recursemode) == :lazy
  end

  def check_exact
    @resource.value(:action) == :exact
  end

  def check_unset
    @resource.value(:action) == :unset
  end

  def check_purge
    @resource.value(:action) == :purge
  end

  def check_set
    @resource.value(:action) == :set
  end

  # TODO: Investigate why we're not using this parameter
  def permission=(_value)
    Puppet.debug @resource.value(:action)
    case @resource.value(:action)
    when :unset
      unset
    when :purge
      purge
    when :exact, :set
      cur_perm = permission
      new_perm = @resource.value(:permission)
      # For comparison purposes, we want to change X to x as it's only useful
      # for setfacl and isn't stored or noted by getfacl.
      lc_cur_perm = cur_perm.map(&:downcase)
      lc_new_perm = new_perm.map(&:downcase)
      perm_to_set = new_perm - cur_perm
      perm_to_set_check = lc_new_perm - lc_cur_perm
      # Unset perms always should match against lowercased x.
      perm_to_unset = cur_perm - new_perm
      perm_to_unset_check = lc_cur_perm - lc_new_perm
      return false if perm_to_set_check.empty? && perm_to_unset_check.empty? # rubocop:disable Lint/ReturnInVoidContext

      # Take supplied perms literally, unset any existing perms which
      # are absent from ACLs given
      if check_exact
        perm_to_unset.each do |perm|
          # Skip base perms in unset step
          if perm =~ %r{^(((u(ser)?)|(g(roup)?)|(m(ask)?)|(o(ther)?)):):}
            Puppet.debug "skipping unset of base perm: #{perm}"
          else
            unset_perm(perm, @resource.value(:path))
          end
        end
      end
      # It's possible we don't have any perms to set if we only removed some
      set_perm(perm_to_set, @resource.value(:path)) unless perm_to_set_check.empty?
    end
  end
end
