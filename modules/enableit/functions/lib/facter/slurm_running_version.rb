# slurm_running_version returns the slurm version actually installed on the host
# (controller or worker), derived from `scontrol --version`. Returns nil when
# slurm is not installed, so it is safe to evaluate fleet-wide.
Facter.add('slurm_running_version') do
  confine kernel: 'Linux'
  setcode do
    if Facter::Core::Execution.which('scontrol')
      # e.g. "slurm 24.11.6" -> "24.11.6"
      out = Facter::Core::Execution.execute('scontrol --version').strip
      out.split(/\s+/)[1]
    end
  end
end
