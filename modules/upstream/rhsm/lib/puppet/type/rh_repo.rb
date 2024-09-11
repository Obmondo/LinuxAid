# frozen_string_literal: true

# @author Craig Dunn crayfishx/puppet-rhsm
Puppet::Type.newtype(:rh_repo) do
  @doc = 'Manage Red Hat subscriptions'

  ensurable do
    newvalue(:present) do
      provider.create unless provider.exists?
    end

    aliasvalue(:enabled, :present)

    newvalue(:absent) do
      provider.destroy if provider.exists?
    end
    aliasvalue(:disabled, :absent)
  end

  newparam(:name) do
    isnamevar
  end
end
