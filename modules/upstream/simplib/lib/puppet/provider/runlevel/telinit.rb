Puppet::Type.type(:runlevel).provide(:telinit) do
  desc <<-EOM
    Set the system runlevel using telinit
  EOM

  commands :telinit => '/sbin/telinit'

  def level
    Facter.value(:runlevel)
  end

  def level_insync?(should, is)
    return should == is
  end

  def level=(should)
    require 'timeout'

    begin
      Timeout::timeout(@resource[:transition_timeout]) do
        execute([command(:telinit), @resource[:name]])
      end
    rescue Timeout::Error
      raise(Puppet::Error, "Could not transition to runlevel #{@resource[:name]} within #{@resource[:transition_timeout]} seconds")
    end
  end

  def persist
    retval = :false

    if @resource[:persist] == :true
      inittab = File.open('/etc/inittab', 'r')
      inittab.each_line do |line|
        if line =~ /^\s*id/
          # We have the initdefault line
          current_value = line.split(':').at(1)
          if current_value.eql?(@resource[:name])
            retval = :true
          end
        end
      end
      inittab.close
    end

    retval
  end

  def persist=(should)
    # Essentially do the same as the read, but save contents to new file
    newfile = String.new
    inittab = File.open('/etc/inittab', 'r')

    found_line = false

    inittab.each_line do |line|
      if line =~ /^\s*id/
        # We've found the default line, so rewrite
        found_line = true
        newfile << "id:#{@resource[:name]}:initdefault:nil\n"
      else
        # Just add this line as is
        newfile << line
      end
    end

    unless found_line
      newfile << "id:#{@resource[:name]}:initdefault:nil\n"
    end

    inittab.close

    inittab = File.open('/etc/inittab', 'w')
    inittab.write(newfile)
    inittab.close
  end
end
