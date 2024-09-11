require 'pathname'
require Pathname.new(__FILE__).dirname + '../../../' + 'puppet/provider/reboot/posix'

Puppet::Type.type(:reboot).provide :linux, parent: :posix do
  confine kernel: :linux

  def initialize(resource = nil)
    Puppet.deprecation_warning _("The 'linux' reboot provider is deprecated and will be removed; use 'posix' instead.")
    super(resource)
  end
end
