# Return the version of SIMP that this server is running or "unknown\n"
Puppet::Functions.create_function(:'simplib::simp_version') do
  # @param strip_whitespace Whether to strip whitespace from the
  #   version string.  Without stripping, the string may end with
  #   a "\n"
  # @return [String] Version string if the version can be detected;
  #   "unknown\n" otherwise
  dispatch :simp_version do
    optional_param 'Boolean', :strip_whitespace
  end

  def simp_version(strip_whitespace = false)
    retval = "unknown\n"

    is_windows = closure_scope['facts']['kernel'].downcase == 'windows'

    version_file = '/etc/simp/simp.version'
    version_file = 'C:\ProgramData\SIMP\simp.version' if is_windows

    if File.readable?(version_file)
      # TODO: Figure out under what circumstances the version string is prefaced
      # with 'simp-'. This is not true for SIMP 6.x
      version = File.read(version_file).gsub('simp-', '')

      retval = version unless version.strip.empty?
    elsif !is_windows
      rpm_query = %q(PATH='/usr/local/bin:/usr/bin:/bin' rpm -q --qf '%{VERSION}-%{RELEASE}\n' simp 2>/dev/null)
      begin
        version = Puppet::Util::Execution.execute(rpm_query, failonfail: true)
      rescue
        version = nil
      end
      retval = version if version
    end

    retval.strip! if strip_whitespace
    retval
  end
end
