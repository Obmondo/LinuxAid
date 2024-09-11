# Returns the contents of /etc/login.defs as a hash with downcased keys
#
Facter.add('login_defs') do
  confine do
    File.exist?('/etc/login.defs') && File.readable?('/etc/login.defs')
  end

  setcode do

    attribute_hash = File.read('/etc/login.defs').lines.
      delete_if{|x| x =~ /^\s*(#|$)/}.
      map{|x| x = x.split(/\s+/); x[0].downcase!; x}.
      to_h

    attribute_hash.each do |k, v|
      # We have a few special cases to take care of

      # Leave the umask as a string
      next if k == 'umask'

      # Change yes/no to true/false
      if v == 'yes'
        attribute_hash[k] = true
      elsif v == 'no'
        attribute_hash[k] = false
      elsif v =~ /^\d+$/
        attribute_hash[k] = v.to_i
      end
    end

    attribute_hash
  end
end
