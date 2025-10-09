require 'puppet/util/selinux'

Puppet::Type.type(:init_ulimit).provide(:sysv) do
  desc <<~EOM
    A provider for updating ulimits in SYSV init.d startup scripts
  EOM

  # TODO: Remove this when Puppet::Util::SELinux is fixed
  class SELinuxKludge # :nodoc:
    include Puppet::Util::SELinux

    def replace_file(target, mode, &content)
      selinux_current_context = get_selinux_current_context(target)

      Puppet::Util.replace_file(target, mode, &content)

      set_selinux_context(target, selinux_current_context)
    end
  end

  def exists?
    # Super hack-fu
    determine_target
    # TODO: Finish refactoring all of this!

    @source_file = File.readlines(@target.to_s)
    @warning_comment = "# Puppet-'#{resource[:item]}' Remove this line if removing the value below."

    # If we have the warning comment, assume that we've got the item.
    # This is mainly done so that we don't mess up any existing code by accident.
    @source_file.find do |line|
      line =~ %r{^#\s*Puppet-'#{resource[:item]}'}
    end
  end

  def create
    new_content = ''

    initial_comments = true
    wrote_content = false

    @source_file.each do |line|
      if initial_comments
        if %r{^\s*#}.match?(line)
          new_content << line
          next
        else
          initial_comments = false
        end
      elsif !wrote_content
        new_content << "#{@warning_comment}\n"
        new_content << "#{ulimit_string}\n"
        wrote_content = true
      end

      new_content << line
    end

    SELinuxKludge.new.replace_file(@target.to_s, 0o644) { |f| f.puts new_content }
  end

  def destroy
    new_content = ''

    skip_line = false
    @source_file.each do |line|
      # Skip the actual item.
      if skip_line && (line =~ %r{^\s*ulimit -#{resource[:item]}})
        skip_line = false
        next
      end

      # Skip the comment
      if %r{^#\s*Puppet-'#{resource[:item]}'}.match?(line)
        skip_line = true
        next
      end

      new_content << line
    end

    SELinuxKludge.new.replace_file(@target.to_s, 0o644) { |f| f.puts new_content }
  end

  def value
    retval = 'UNKNOWN'
    found_comment = false
    @source_file.each do |line|
      if found_comment
        # This really shouldn't happen, but it's possible that someone might
        # stuff some empty lines in there or something.
        next unless line =~ %r{^\s*ulimit -#{resource[:item]} (.*)}
        retval = Regexp.last_match(1)
        break

      end
      if %r{^#\s*Puppet-'#{resource[:item]}'}.match?(line)
        found_comment = true
        next
      end
    end

    retval
  end

  def value=(_should)
    new_content = @source_file.dup

    comment_line = @source_file.find_index { |x| x =~ %r{^#\s*Puppet-'#{resource[:item]}'} }
    ulimit_match = @source_file.find_index { |x| x =~ %r{^\s*ulimit -#{resource[:item]}} }

    if comment_line && !ulimit_match
      # Someone deleted the ulimit, but not the comment!
      new_content.insert(comment_line + 1, ulimit_string)

    elsif ulimit_match < comment_line
      # Well, this is a bit of a mess, delete the comment and insert above the
      # ulimit
      new_content.delete_at[comment_line]
      new_content.insert(ulimit_match, @warning_comment)
    else
      # Get rid of the current ulimit and replace it with the new one.
      new_content[ulimit_match] = ulimit_string
    end

    SELinuxKludge.new.replace_file(@target.to_s, 0o644) { |f| f.puts new_content }
  end

  private

  # Builds the ulimit string to write out to the file.
  def ulimit_string
    toret = 'ulimit'

    if resource[:limit_type] != 'both'
      toret << " -#{resource[:limit_type][0].chr.upcase}"
    end

    toret << " -#{resource[:item]} #{resource[:value]}\n"
  end

  def determine_target
    @provider = :redhat
    @target = @resource[:target]

    if @target[0].chr != '/'
      @target = "/etc/init.d/#{@target}"
    end

    raise(Puppet::ParseError, "File '#{@target}' not found.") unless File.exist?(@target)
  end
end
