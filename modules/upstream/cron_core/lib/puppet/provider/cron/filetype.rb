require 'puppet/util/filetype'

class Puppet::Provider::Cron
  # This class defines the crontab filetypes
  class FileType < Puppet::Util::FileType
    class << self
      define_method(:base_newfiletype, instance_method(:newfiletype))

      # Puppet::Util::FileType.newfiletype will raise an exception if
      # an already-defined filetype is re-defined. Unfortunately, there's
      # a chance that this file could be loaded multiple times by Puppet's
      # autoloader meaning that, without this wrapper, the crontab filetypes
      # would be re-defined, causing Puppet to raise an exception.
      def newfiletype(name, &block)
        return if @filetypes && @filetypes.key?(name)

        base_newfiletype(name, &block)
      end
    end

    # Handle Linux-style cron tabs.
    #
    # TODO: We can possibly eliminate the "-u <username>" option in cmdbase
    # by just running crontab under <username>'s uid (like we do for suntab
    # and aixtab). It may be worth investigating this alternative
    # implementation in the future. This way, we can refactor all three of
    # our cron file types into a common crontab file type.
    newfiletype(:crontab) do
      def initialize(user)
        self.path = user
      end

      def path=(user)
        begin
          @uid = Puppet::Util.uid(user)
        rescue Puppet::Error => detail
          raise FileReadError, _('Could not retrieve user %{user}: %{detail}') % { user: user, detail: detail }, detail.backtrace
        end

        # XXX We have to have the user name, not the uid, because some
        # systems *cough*linux*cough* require it that way
        @path = user
      end

      # Read a specific @path's cron tab.
      def read
        unless Puppet::Util.uid(@path)
          Puppet.debug _('The %{path} user does not exist. Treating their crontab file as empty in case Puppet creates them in the middle of the run.') % { path: @path }

          return ''
        end

        Puppet::Util::Execution.execute("#{cmdbase} -l", failonfail: true, combine: true)
      rescue => detail
        case detail.to_s
        when %r{no crontab for}
          return ''
        when %r{are not allowed to}
          Puppet.debug _('The %{path} user is not authorized to use cron. Their crontab file is treated as empty in case Puppet authorizes them in the middle of the run (by, for example, modifying the cron.deny or cron.allow files).') % { path: @path }

          return ''
        else
          raise FileReadError, _('Could not read crontab for %{path}: %{detail}') % { path: @path, detail: detail }, detail.backtrace
        end
      end

      # Remove a specific @path's cron tab.
      def remove
        cmd = "#{cmdbase} -r"
        if ['Darwin', 'FreeBSD', 'DragonFly'].include?(Facter.value('operatingsystem'))
          cmd = "/bin/echo yes | #{cmd}"
        end

        Puppet::Util::Execution.execute(cmd, failonfail: true, combine: true)
      end

      # Overwrite a specific @path's cron tab; must be passed the @path name
      # and the text with which to create the cron tab.
      #
      # TODO: We should refactor this at some point to make it identical to the
      # :aixtab and :suntab's write methods so that, at the very least, the pipe
      # is not created and the crontab command's errors are not swallowed.
      def write(text)
        unless Puppet::Util.uid(@path)
          raise Puppet::Error, _("Cannot write the %{path} user's crontab: The user does not exist") % { path: @path }
        end

        # this file is managed by the OS and should be using system encoding
        IO.popen("#{cmdbase} -", 'w', encoding: Encoding.default_external) do |p|
          p.print text
        end
      end

      private

      # Only add the -u flag when the @path is different.  Fedora apparently
      # does not think I should be allowed to set the @path to my own user name
      def cmdbase
        return 'crontab' if @uid == Puppet::Util::SUIDManager.uid || Facter.value(:operatingsystem) == 'HP-UX'

        "crontab -u #{@path}"
      end
    end

    # SunOS has completely different cron commands; this class implements
    # its versions.
    newfiletype(:suntab) do
      # Read a specific @path's cron tab.
      def read
        unless Puppet::Util.uid(@path)
          Puppet.debug _('The %{path} user does not exist. Treating their crontab file as empty in case Puppet creates them in the middle of the run.') % { path: @path }

          return ''
        end

        Puppet::Util::Execution.execute(['crontab', '-l'], cronargs)
      rescue => detail
        case detail.to_s
        when %r{can't open your crontab}
          return ''
        when %r{you are not authorized to use cron}
          Puppet.debug _('The %{path} user is not authorized to use cron. Their crontab file is treated as empty in case Puppet authorizes them in the middle of the run (by, for example, modifying the cron.deny or cron.allow files).') % { path: @path }

          return ''
        else
          raise FileReadError, _('Could not read crontab for %{path}: %{detail}') % { path: @path, detail: detail }, detail.backtrace
        end
      end

      # Remove a specific @path's cron tab.
      def remove
        Puppet::Util::Execution.execute(['crontab', '-r'], cronargs)
      rescue => detail
        raise FileReadError, _('Could not remove crontab for %{path}: %{detail}') % { path: @path, detail: detail }, detail.backtrace
      end

      # Overwrite a specific @path's cron tab; must be passed the @path name
      # and the text with which to create the cron tab.
      def write(text)
        # this file is managed by the OS and should be using system encoding
        output_file = Tempfile.new('puppet_suntab', encoding: Encoding.default_external)
        begin
          output_file.print text
          output_file.close
          # We have to chown the stupid file to the user.
          File.chown(Puppet::Util.uid(@path), nil, output_file.path)
          Puppet::Util::Execution.execute(['crontab', output_file.path], cronargs)
        rescue => detail
          raise FileReadError, _('Could not write crontab for %{path}: %{detail}') % { path: @path, detail: detail }, detail.backtrace
        ensure
          output_file.close
          output_file.unlink
        end
      end
    end

    #  Support for AIX crontab with output different than suntab's crontab command.
    newfiletype(:aixtab) do
      # Read a specific @path's cron tab.
      def read
        unless Puppet::Util.uid(@path)
          Puppet.debug _('The %{path} user does not exist. Treating their crontab file as empty in case Puppet creates them in the middle of the run.') % { path: @path }

          return ''
        end

        Puppet::Util::Execution.execute(['crontab', '-l'], cronargs)
      rescue => detail
        case detail.to_s
        when %r{open.*in.*directory}
          return ''
        when %r{not.*authorized.*cron}
          Puppet.debug _('The %{path} user is not authorized to use cron. Their crontab file is treated as empty in case Puppet authorizes them in the middle of the run (by, for example, modifying the cron.deny or cron.allow files).') % { path: @path }

          return ''
        else
          raise FileReadError, _('Could not read crontab for %{path}: %{detail}') % { path: @path, detail: detail }, detail.backtrace
        end
      end

      # Remove a specific @path's cron tab.
      def remove
        Puppet::Util::Execution.execute(['crontab', '-r'], cronargs)
      rescue => detail
        raise FileReadError, _('Could not remove crontab for %{path}: %{detail}') % { path: @path, detail: detail }, detail.backtrace
      end

      # Overwrite a specific @path's cron tab; must be passed the @path name
      # and the text with which to create the cron tab.
      def write(text)
        # this file is managed by the OS and should be using system encoding
        output_file = Tempfile.new('puppet_aixtab', encoding: Encoding.default_external)

        begin
          output_file.print text
          output_file.close
          # We have to chown the stupid file to the user.
          File.chown(Puppet::Util.uid(@path), nil, output_file.path)
          Puppet::Util::Execution.execute(['crontab', output_file.path], cronargs)
        rescue => detail
          raise FileReadError, _('Could not write crontab for %{path}: %{detail}') % { path: @path, detail: detail }, detail.backtrace
        ensure
          output_file.close
          output_file.unlink
        end
      end
    end
  end
end
