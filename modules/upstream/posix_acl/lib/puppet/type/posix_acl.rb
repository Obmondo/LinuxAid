# frozen_string_literal: true

require 'set'
require 'pathname'
require 'English'
# rubocop:disable Naming/MethodParameterName
Puppet::Type.newtype(:posix_acl) do
  desc <<-EOT
     Ensures that a set of ACL permissions are applied to a given file
     or directory.

      Example:

          posix_acl { '/var/www/html':
            action      => exact,
            permission  => [
              'user::rwx',
              'group::r-x',
              'mask::rwx',
              'other::r--',
              'default:user::rwx',
              'default:user:www-data:r-x',
              'default:group::r-x',
              'default:mask::rwx',
              'default:other::r--',
            ],
            provider    => posixacl,
            recursive   => true,
          }

      In this example, Puppet will ensure that the user and group
      permissions are set recursively on /var/www/html as well as add
      default permissions that will apply to new directories and files
      created under /var/www/html

      Setting an ACL can change a file's mode bits, so if the file is
      managed by a File resource, that resource needs to set the mode
      bits according to what the calculated mode bits will be, for
      example, the File resource for the ACL above should be:

          file { '/var/www/html':
                 mode => 754,
               }
  EOT

  newparam(:action) do
    desc 'What do we do with this list of ACLs? Options are set, unset, exact, and purge'
    newvalues(:set, :unset, :exact, :purge)
    defaultto :set
  end

  newparam(:ignore_missing) do
    desc 'What to do if files are missing:
      false: fail run,
      quiet: quietly do nothing,
      notify: do not try to to set ACL, but add notice to run'
    newvalues(:false, :quiet, :notify)
    defaultto :false
  end

  newparam(:path) do
    desc 'The file or directory to which the ACL applies.'
    isnamevar
    validate do |value|
      path = Pathname.new(value)
      raise ArgumentError, "Path must be absolute: #{path}" unless path.absolute?
    end
  end

  newparam(:recursemode) do
    desc "Should Puppet apply the ACL recursively with the -R option or
      apply it to individual files?

      lazy means -R option
      deep means apply to every file"

    newvalues(:lazy, :deep)
    defaultto :lazy
  end

  # Credits to @itdoesntwork
  # http://stackoverflow.com/questions/26878341/how-do-i-tell-if-one-path-is-an-ancestor-of-another
  def self.descendant?(a, b)
    a_list = File.expand_path(a).split('/')
    b_list = File.expand_path(b).split('/')

    b_list[0..a_list.size - 1] == a_list && b_list != a_list
  end

  # Snippet based on upstream Puppet (ASL 2.0)
  %i[posix_acl file].each do |autorequire_type|
    autorequire(autorequire_type) do
      req = []
      path = Pathname.new(self[:path])
      if autorequire_type != :posix_acl
        if self[:recursive] == :true
          catalog.resources.select do |r|
            r.is_a?(Puppet::Type.type(autorequire_type)) && self.class.descendant?(self[:path], r[:path])
          end.each do |found| # rubocop:disable Style/MultilineBlockChain
            req << found[:path]
          end
        end
        req << self[:path]
      end
      unless path.root?
        # Start at our parent, to avoid autorequiring ourself
        parents = path.parent.enum_for(:ascend)
        # should this be = or == ? I don't know
        if found = parents.find { |p| catalog.resource(autorequire_type, p.to_s) } # rubocop:disable Lint/AssignmentInCondition
          req << found.to_s
        end
      end
      req
    end
  end
  # End of Snippet

  autorequire(:package) do
    ['acl']
  end

  newproperty(:permission, array_matching: :all) do
    desc 'ACL permission(s).'

    def is_to_s(value)
      if value == :absent || value.include?(:absent)
        super
      else
        value.sort.inspect
      end
    end

    def should_to_s(value)
      if value == :absent || value.include?(:absent)
        super
      else
        value.sort.inspect
      end
    end

    def retrieve
      provider.permission
    end

    # Remove permission bits from an ACL line, eg:
    # 'user:root:rwx' becomes 'user:root:'
    def strip_perms(pl)
      Puppet.debug 'permission.strip_perms'
      value = []
      pl.each do |perm|
        unless perm =~ %r{^(((u(ser)?)|(g(roup)?)|(m(ask)?)|(o(ther)?)):):}
          perm = perm.split(':', -1)[0..-2].join(':')
          value << perm
        end
      end
      value.sort
    end

    # in unset_insync and set_insync the test_should has been added as a work around
    #  to prevent puppet-posix_acl from interpreting recursive permission notation (e.g. rwX)
    #  from causing a false mismatch.  A better solution needs to be implemented to
    #  recursively check permissions, not rely upon getfacl
    def unset_insync(cur_perm)
      # Puppet.debug "permission.unset_insync"
      test_should = []
      @should.each { |x| test_should << x.downcase }
      cp = strip_perms(cur_perm)
      sp = strip_perms(test_should)
      (sp - cp).sort == sp
    end

    # Make sure we are not misinterpreting recursive permission notation (e.g. rwX) when
    # comparing current to new perms.
    def set_insync(cur_perm) # rubocop:disable Naming/AccessorMethodName
      lc_cur_perm = cur_perm.map(&:downcase).uniq.sort
      should = @should.map(&:downcase).uniq.sort
      (lc_cur_perm.sort == should) || (provider.check_set && (should - lc_cur_perm).empty?)
    end

    def purge_insync(cur_perm)
      # Puppet.debug "permission.purge_insync"
      cur_perm.each do |perm|
        # If anything other than the mode bits are set, we're not in sync
        return false unless perm =~ %r{^(((u(ser)?)|(g(roup)?)|(o(ther)?)):):}
      end
      true
    end

    def insync?(is)
      Puppet.debug "permission.insync? is: #{is.inspect} @should: #{@should.inspect}"
      # handle missing file
      if provider.permission.include?('DOES_NOT_EXIST')
        case @resource.value(:ignore_missing)
        when :false
          raise ArgumentError, "Path #{@resource.value(:path)} not found"
        when :quiet
          return true
        when :notify
          Puppet.notice("Not setting ACL for #{@resource.value(:path)} as it does not exist.")
          return true
        end
      end
      return purge_insync(is) if provider.check_purge
      return unset_insync(is) if provider.check_unset

      set_insync(is)
    end

    # Munge into normalised form
    munge do |acl|
      result = ''
      a = acl.split ':', -1 # -1 keeps trailing empty fields.
      raise ArgumentError, "Too few fields.  At least 3 required, got #{a.length}." if a.length < 3
      raise ArgumentError, "Too many fields.  At most 4 allowed, got #{a.length}."  if a.length > 4

      if a.length == 4
        default, type, who, perms = a
        raise ArgumentError, %(First field of 4 must be "d" or "default", got "#{default}".) unless %w[d default].include?(default)

        result += 'default:'
      else
        type, who, perms = a
      end

      result += case type
                when 'u', 'user'
                  'user:'
                when 'g', 'group'
                  'group:'
                when 'o', 'other'
                  'other:'
                when 'm', 'mask'
                  'mask:'
                else
                  raise ArgumentError, %(Unknown type "#{t}", expected "user", "group", "other" or "mask".)
                end
      result += "#{who}:"
      if perms.match?(%r{^[0-7]$})
        octal = perms.oct
        result += "#{octal & 4 == 4 ? 'r' : '-'}#{octal & 2 == 2 ? 'w' : '-'}#{octal & 1 == 1 ? 'x' : '-'}"
      else
        match = %r{^(?<read>r)?(?<write>w)?(?<execute>[xX])?$}.match(perms.tr('-', ''))
        raise ArgumentError, %(Invalid permission set "#{p}".) unless match

        %w[read write execute].each do |perm|
          result += match[perm] || '-'
        end
      end
      result
    end
  end

  newparam(:recursive) do
    desc 'Apply ACLs recursively.'
    newvalues(:true, :false)
    defaultto :false
  end

  def self.pick_default_perms(acl)
    acl.reject { |a| a.split(':', -1).length == 4 }
  end

  def newchild(path)
    options = @original_parameters.merge(name: path).reject { |_param, value| value.nil? } # rubocop:disable Style/CollectionCompact
    options[:permission] = self.class.pick_default_perms(options[:permission]) if !File.directory?(options[:name]) && options.include?(:permission)
    %i[recursive recursemode path].each do |param|
      options.delete(param) if options.include?(param)
    end
    self.class.new(options)
  end

  def generate
    return [] unless self[:recursive] == :true && self[:recursemode] == :deep

    results = []
    paths = Set.new
    if File.directory?(self[:path])
      Dir.chdir(self[:path]) do
        Dir['**/*'].each do |path|
          paths << File.join(self[:path], path)
        end
      end
    end
    # At the time we generate extra resources, all the files might not be present yet.
    # In prediction to that we also create ACL resources for child file resources that
    # might not have been applied yet.
    catalog.resources.select do |r|
      r.is_a?(Puppet::Type.type(:file)) && self.class.descendant?(self[:path], r[:path])
    end.each do |found| # rubocop:disable Style/MultilineBlockChain
      paths << found[:path]
    end
    paths.each do |path|
      results << newchild(path)
    end
    results
  end

  validate do
    raise(Puppet::Error, 'permission is a required property.') unless self[:permission]
  end
end
# rubocop:enable Naming/MethodParameterName
