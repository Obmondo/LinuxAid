# _Description_
#
# Set a fact to return the version of GDM that is installed.
# This is useful for applying the correct configuration file syntax.
#
Facter.add('gdm_version') do
  confine { File.exist?('/usr/sbin/gdm') && File.executable?('/usr/sbin/gdm') }
  setcode do
    `/usr/sbin/gdm --version`.chomp.split(%r{\s+})[1]
  end
end
