Puppet::Type.type(:simp_file_line).provide(:ruby) do
  desc <<~EOM
    Provides the ability to prepend, append, or simply add lines to a file.

    Will create the file if it doesn't exist.
  EOM

  def exists?
    if file_managed?
      Puppet.debug("Skipping #{resource.ref} due to deconflict = :true")
      true
    else
      lines.find do |line|
        line.chomp == resource[:line].chomp
      end
    end
  end

  def create
    if resource[:match]
      handle_create_with_match
    else
      handle_create_without_match
    end
  end

  def destroy
    local_lines = lines
    File.open(resource[:path], 'w') do |fh|
      fh.write(local_lines.reject { |l| l.chomp == resource[:line] }.join(''))
    end
  end

  private

  def file_managed?
    # Return true/false based on whether or not the target file already has its
    # content managed by a File resource.
    # If we are not deconflicting, then throw an error since this is bad.

    file_resource = resource.catalog.resource("File[#{resource[:path]}]")

    if file_resource && file_resource[:replace] &&
       (file_resource[:source] || file_resource[:content])
      return true if resource[:deconflict] == :true

      raise Puppet::Error, "'#{resource.ref}' conflicts with #{file_resource.ref}" \
                           " resource in file #{file_resource.file} at line" \
                           "  #{file_resource.line}. If you wish to have the File" \
                           " resource win, use the 'deconflict' option in #{resource.ref}" \
                           " in #{resource.file}:#{resource.line}."

    end

    false
  end

  def lines
    # If this type is ever used with very large files, we should
    #  write this in a different way, using a temp
    #  file; for now assuming that this type is only used on
    #  small-ish config files that can fit into memory without
    #  too much trouble.
    @lines ||= File.readlines(resource[:path])
  end

  def handle_create_with_match
    regex = resource[:match] ? Regexp.new(resource[:match]) : nil
    match_count = lines.count { |l| regex.match(l) }
    if match_count > 1
      raise Puppet::Error, "More than one line in file '#{resource[:path]}' matches pattern '#{resource[:match]}'"
    end
    File.open(resource[:path], 'w') do |fh|
      newlines = [resource[:line] + "\n"]

      lines.each do |l|
        newlines << (regex.match(l) ? resource[:line] : l)
      end

      if match_count == 0
        if resource[:prepend] != :true
          newlines << newlines.shift
        end
      else
        newlines.shift
      end

      fh.puts(newlines)
    end
  end

  def handle_create_without_match
    if resource[:prepend] != :true
      File.open(resource[:path], 'a') do |fh|
        fh.puts resource[:line]
      end
    else
      old_lines = lines
      File.open(resource[:path], 'w') do |fh|
        fh.puts(resource[:line])
        fh.puts(old_lines)
      end
    end
  end
end
