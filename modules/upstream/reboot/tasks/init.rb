#!/opt/puppetlabs/puppet/bin/ruby
require 'facter'
require 'json'

class Reboot # rubocop:disable Style/ClassAndModuleChildren
  # Class for rebooting the system. This doesn't need to be a class but it allows for automated testing
  class Task
    attr_accessor :timeout

    def initialize(opts = {})
      @timeout       = opts['timeout'].to_i
      @message       = opts['message']
      @shutdown_only = opts['shutdown_only'] || false

      # Force a minimum timeout of 3 seconds to allow the task response to be delivered.
      @timeout = 3 if @timeout < 3
    end

    def execute!
      # Actually shut down the computer
      case Facter.value(:kernel)
      when 'windows'
        async_command(windows_shutdown_command(timeout: @timeout, message: @message))
      when 'SunOS'
        async_command(unix_shutdown_command(timeout: @timeout, message: @message))
      else
        # Specify timeout in minutes, or now. Let the forked process sleep to handle seconds.
        timeout_min = @timeout / 60
        timeout_min = (timeout_min > 0) ? "+#{timeout_min}" : 'now'
        timeout_sec = timeout % 60
        async_command(unix_shutdown_command(timeout: timeout_min, message: @message), timeout_sec)
      end
    end

    def async_command(cmd, wait_time = nil)
      case Facter.value(:kernel)
      when 'windows'
        # This appears to be the only way to get the processes to properly detach
        # themselves, it was a HUGE PAIN to fugure out
        require 'win32/process'
        Process.create(
          command_line: "cmd /c start #{cmd}",
          creation_flags: Process::DETACHED_PROCESS,
        )
      else
        # Fork the process so that we can have one return the status and one
        # actually do the work
        if fork.nil?
          # Detatch itself completely
          Process.daemon
          # Wait the prescribed amount of time
          sleep wait_time if wait_time
          # Replace itself with the reboot command
          exec(*cmd)
        end
      end
    end

    def shutdown_executable_windows
      if File.exist?("#{ENV['SYSTEMROOT']}\\sysnative\\shutdown.exe")
        "#{ENV['SYSTEMROOT']}\\sysnative\\shutdown.exe"
      elsif File.exist?("#{ENV['SYSTEMROOT']}\\system32\\shutdown.exe")
        "#{ENV['SYSTEMROOT']}\\system32\\shutdown.exe"
      else
        'shutdown.exe'
      end
    end

    def windows_shutdown_command(params)
      message_params   = ['/c', "\"#{params[:message]}\""] if params[:message]
      reboot_param     = @shutdown_only ? '/s' : '/r'
      [shutdown_executable_windows, reboot_param, '/t', params[:timeout], '/d', 'p:4:1', message_params].join(' ')
    end

    def unix_shutdown_command(params)
      require 'shellwords'
      escaped_message = Shellwords.escape(params[:message])
      flags = if Facter.value(:kernel) == 'SunOS'
                init_level = @shutdown_only ? '5' : '6'
                ['-y', '-i', init_level, '-g', params[:timeout], escaped_message]
              else
                reboot_flag = @shutdown_only ? '-P' : '-r'
                [reboot_flag, params[:timeout], escaped_message]
              end
      ['shutdown', flags, '</dev/null', '>/dev/null', '2>&1', '&'].flatten
    end
  end
end

# Actually run the reboot if we got piped input
unless STDIN.tty?
  reboot = Reboot::Task.new(JSON.parse(STDIN.read))
  reboot.execute!

  result = {
    'status' => 'queued',
    'timeout' => reboot.timeout,
  }
  JSON.dump(result, STDOUT)
end
