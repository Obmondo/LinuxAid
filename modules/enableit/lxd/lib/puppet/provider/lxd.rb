require 'json'

class Puppet::Provider::LXD < Puppet::Provider

  # Without initvars commands won't work.
  initvars
  commands :lxc => 'lxc'

end
