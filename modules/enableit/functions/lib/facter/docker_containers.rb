Facter.add(:docker_containers) do
  confine :kernel => :linux
  confine { Facter::Core::Execution.which('docker') }

  setcode do
    # The output are lines of hash-maps without a surrounding array. We then
    # join lines with a comma to turn it into valid JSON.
    containers = Facter::Util::Resolution
                   .exec('docker container ps --format \'{"state": {{ .State|json }}, "status": {{ .Status|json }}, "image": {{ .Image|json }}, "name": {{ .Names|json }}}\'')
                   .split("\n")
                   .join(',')
    JSON.parse("[#{containers}]")
  end
end
