begin
  require 'puppet_x/voxpupuli/corosync/provider/crmsh'
rescue LoadError
  require 'pathname' # WORKAROUND #14073, #7788 and SERVER-973
  corosync = Puppet::Module.find('corosync', Puppet[:environment].to_s)
  raise(LoadError, "Unable to find corosync module in modulepath #{Puppet[:basemodulepath] || Puppet[:modulepath]}") unless corosync
  require File.join corosync.path, 'lib/puppet_x/voxpupuli/corosync/provider/crmsh'
end

Puppet::Type.type(:cs_shadow).provide(:crm, parent: PuppetX::Voxpupuli::Corosync::Provider::Crmsh) do
  commands crm_shadow: 'crm_shadow'
  commands cibadmin: 'cibadmin'
  commands crm: 'crm'

  def self.instances
    block_until_ready(120, true)
    []
  end

  # Need this available at the provider level, for types
  def get_epoch(cib = nil)
    PuppetX::Voxpupuli::Corosync::Provider::Crmsh.get_epoch(cib)
  end

  def epoch
    get_epoch(resource.cib)
  end

  def insync?(cib)
    get_epoch == get_epoch(cib)
  end

  def sync(_cib)
    PuppetX::Voxpupuli::Corosync::Provider::Crmsh.sync_shadow_cib(@resource[:name])
  end
end
