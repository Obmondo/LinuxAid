Puppet::Type.type(:script_umask).provide(:ruby) do
  desc <<-EOM
    Set the ``umask`` at the top of a shell script
  EOM

  def umask
    # Just skip it all if the file doesn't exist.
    if not File.exist?(@resource[:name]) then
      return @resource[:umask]
    end

    umasks = []
    fh = File.open(@resource[:name],'r')
    fh.each_line do |line|
      next if line =~ /\s*#/

      if line =~ /^\s*umask\s+(\d{3,4})/ then
        umasks << $1
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
      if line =~ /^(\s*umask\s+)(\d{3,4})(.*)/ then
        output << "#{$1}#{should}#{$3}"
      else
        output << line.chomp
      end
    end

    File.open(@resource[:name],'w') { |fh|
      fh.rewind
      fh.puts(output.join("\n"))
    }
  end
end
