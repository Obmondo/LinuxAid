module AuditdTestUtil
  # An object that holds the assessment of a given nodes ruleset
  class AuditdRules
    RULE_IGNORE_LIST = [
      # Ignore anything with a 'path' entry since those may not exist on the
      # target system.
      %r{path=},
      # Ignore all file watches since the files may not exist
      %r{^-w},
      # Ignore any uid or gid watches where the user is not root or 0 since the
      # user may not exist
      %r{(uid|gid)=(?!rot|0)}
    ]

    # @return [Array[String]]
    #   The rules found on the system after filtering
    attr_reader :rules

    # @return [Array[String]]
    #   The rules found on the system before filtering
    attr_reader :system_rules

    # @return [Array[String]]
    #   Warnings found in the system rules
    attr_reader :warnings

    # @return [Array[String]]
    #   Errors found in the system rules
    attr_reader :errors

    # @param host [Beaker::Host]
    #   The host to operate on
    #
    # @param ignore [Array[Regexp]]
    #   Regular expressions that denote invalid rules
    def initialize(host, ignore = RULE_IGNORE_LIST)
      @rules        = []
      @warnings     = []
      @errors       = []
      @system_rules = on(host,'cat /etc/audit/audit.rules').stdout.lines.map(&:strip)

      if @system_rules.grep(/no rules/i).empty?
        require 'securerandom'

        @rules = @system_rules.dup
        @rules.delete_if do |rule|
          ignore.any? do |regexp|
            regexp.match?(rule)
          end
        end

        tempname = '/tmp/auditd-' + SecureRandom.uuid+ '.rules'

        create_remote_file(host, tempname, ['-c', @rules].flatten.join("\n"))
        on(host, "chmod 600 #{tempname}")

        auditctl_output = on(host,
          "auditctl -R #{tempname}",
          :accept_all_exit_codes => true
        ).output.lines.map(&:strip)

        error_found = false
        auditctl_output.each_with_index do |line, i|
          if error_found
            error_found = false
            next
          end

          next_line = auditctl_output[i+1]

          if line =~ /^error/i
            # The error line number is in the next line down
            if next_line =~ /(line \d+)/
              @errors << line + ': ' + $1

              error_found = true
            end

            next
          end

          if line =~ /^warning/i
            @warnings << line
          end
        end
      end
    end

    # Convert the errors and warnings to a well-formatted string
    #
    # @return [String]
    def to_s
      output = ['Rule Warnings:']

      if @warnings.empty?
        output << '  * None'
      else
        output << %{  * #{@warnings.join("\n  *")}}
      end

      output << ['']
      output << ['Rule Errors:']

      if @errors.empty?
        output << '  * None'
      else
        output << %{  * #{@errors.join("\n  *")}}
      end

      output.join("\n")
    end
  end
end
