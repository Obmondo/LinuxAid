Puppet::Type.type(:script_umask).provide(:ruby) do
  desc <<~EOM
    Set the ``umask`` at the top of a shell script
  EOM

  def umask
    # Just skip it all if the file doesn't exist.
    unless File.exist?(@resource[:name])
      return @resource[:umask]
    end

    umasks = []
    fh = File.open(@resource[:name], 'r')
    fh.each_line do |line|
      next if %r{\s*#}.match?(line)

      if line =~ %r{^\s*umask\s+(\d{3,4})}
        umasks << Regexp.last_match(1)
      end
    end
    fh.close

    # Doing this so that, if multiple different umasks are found, we still get
    # the proper match.
    umasks.uniq.join(',')
  end

  def umask=(should)
    output = []
    File.read(@resource[:name]).each_line do |line|
      output << if line =~ %r{^(\s*umask\s+)(\d{3,4})(.*)}
                  "#{Regexp.last_match(1)}#{should}#{Regexp.last_match(3)}"
                else
                  line.chomp
                end
    end

    File.open(@resource[:name], 'w') do |fh|
      fh.rewind
      fh.puts(output.join("\n"))
    end
  end
end
