# frozen_string_literal: true

require 'etc'

# class to use in openssl providers to handle file permission (mode, group and owner)
class Puppet::Provider::Openssl < Puppet::Provider
  include Puppet::Util::POSIX

  def owner
    if File.exist?(@resource[:path])
      Etc.getpwuid(File.stat(@resource[:path]).uid).name
    else
      :absent
    end
  end

  def owner=(should)
    File.chown(uid(should), nil, resource[:path])
  rescue StandardError => e
    raise Puppet::Error, _("Failed to set owner to '#{should}': #{e}"), detail.backtrace
  end

  def group
    if File.exist?(@resource[:path])
      Etc.getgrgid(File.stat(@resource[:path]).gid).name
    else
      :absent
    end
  end

  def group=(should)
    File.chown(nil, gid(should), resource[:path])
  rescue StandardError => e
    raise Puppet::Error, _("Failed to set group to '#{should}': #{e}"), detail.backtrace
  end

  # Return the mode as an octal string, not as an integer.
  def mode
    if File.exist?(@resource[:path])
      format('0%o', (File.stat(@resource[:path]).mode & 0o07777))
    else
      :absent
    end
  end

  # Set the file mode, converting from a string to an integer.
  def mode=(should)
    File.chmod(Integer("0#{should}"), @resource[:path])
  end

  def set_file_perm(filename, owner = nil, group = nil, mode = nil)
    File.chown(uid(owner), nil, resource[:path]) if owner
    File.chown(nil, gid(group), resource[:path]) if group
    File.chmod(Integer("0#{mode}"), filename) if mode
  end
end
