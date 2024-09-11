require_relative './confine.rb'

Puppet::Functions.create_function(:confine_systemd) do
  dispatch :confine_systemd do
  end

  def confine_systemd()
    init_system = closure_scope['facts']['init_system']

    unless init_system == 'systemd'
      raise ConfinedException, 'Only systemd systems are supported'
    end
  end
end
