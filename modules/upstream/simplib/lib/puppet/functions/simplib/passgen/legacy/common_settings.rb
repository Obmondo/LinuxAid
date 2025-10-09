# Returns common settings used by simplib::passgen in legacy mode
#
Puppet::Functions.create_function(:'simplib::passgen::legacy::common_settings') do
  # @return [Hash] Settings Hash containing 'keydir', 'user', 'group',
  #   'dir_mode' and 'file_mode' attributes
  #
  dispatch :common_settings do
  end

  # Mechanism to share common settings
  def common_settings
    require 'etc'

    scope = closure_scope

    {
      'keydir'    => File.join(Puppet.settings[:vardir], 'simp', 'environments', scope.lookupvar('::environment'), 'simp_autofiles', 'gen_passwd'),
      'user'      => Etc.getpwuid(Process.uid).name,
      'group'     => Etc.getgrgid(Process.gid).name,
      'dir_mode'  => 0o750,
      'file_mode' => 0o640,
    }
  end
end
