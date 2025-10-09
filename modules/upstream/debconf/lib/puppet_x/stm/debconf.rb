# frozen_string_literal: true

# A private class to communicate with the debconf database
module PuppetX
  class Debconf
    # The regular expression used to parse the debconf-communicate output
    DEBCONF_COMMUNICATE = %r{
      ^([0-9]+)                 # error code
      \s*                       # whitespace
      (.*)                      # return value
      \s*$                      # optional trailing spaces
    }x.freeze

    def initialize(pipe)
      @pipe = pipe
    end

    # Open communication channel with the debconf database
    def self.communicate(package)
      Puppet.debug("Debconf: open pipe to debconf-communicate for #{package}")

      pipe = IO.popen("/usr/bin/debconf-communicate #{package}", 'w+')

      raise(Puppet::Error, 'Debconf: failed to open pipe to debconf-communicate') unless pipe

      # Call block for pipe
      yield new(pipe) if block_given?

      # Close pipe and finish, ignore remaining output from command
      pipe.close_write
      pipe.read(nil)
      pipe.close_read
      @pipe = nil
    end

    # Send a command to the debconf-communicate pipe and collect response
    def send(command)
      Puppet.debug("Debconf: send #{command}")

      @pipe.puts(command)
      response = @pipe.gets("\n")

      raise(Puppet::Error, 'Debconf: debconf-communicate unexpectedly closed pipe') unless response

      raise(Puppet::Error, "Debconf: debconf-communicate returned (#{response})") unless DEBCONF_COMMUNICATE.match(response)

      # Response is devided into the return code (casted to int) and the
      # result text. Depending on the context the text could be an error
      # message or the value of an item.
      retcode = Regexp.last_match(1).to_i
      retmesg = Regexp.last_match(2)

      [retcode, retmesg]
    end

    # Get an item from the debconf database
    # Return the value of the item or nil if the item is not found
    def get(item)
      resultcode, resultmesg = send("GET #{item}")

      # Check for errors
      case resultcode
      when 0 then resultmesg    # OK
      when 10 then nil          # item doesn't exist
      else
        raise(Puppet::Error, "Debconf: 'GET #{item}' returned #{resultcode}: #{resultmesg}")
      end
    end

    # Get the seen flag for an item from the debconf database
    # Return a boolean true or false
    def seen?(item)
      resultcode, resultmesg = send("FGET #{item} seen")

      # Check for errors
      case resultcode
      when 0 then (resultmesg == 'true')
      when 10 then false
      else
        raise(Puppet::Error, "Debconf: 'FGET #{item} seen' returned #{resultcode}: #{resultmesg}")
      end
    end

    # Unregister an item in the debconf database
    def unregister(item)
      resultcode, resultmesg = send("UNREGISTER #{item}")

      # Check for errors
      raise(Puppet::Error, "Debconf: 'UNREGISTER #{item}' returned #{resultcode}: #{resultmesg}") unless resultcode.zero?

      @property_hash = {}
    end
  end
end
