# frozen_string_literal: true

# @author Craig Dunn crayfishx/puppet-rhsm
Puppet::Type.newtype(:rh_subscription) do
  @doc = 'Manage Red Hat subscriptions'

  ensurable

  newparam(:name, isnamevar: true) do # rubocop:disable Lint/EmptyBlock
  end

  newparam(:serial) do # rubocop:disable Lint/EmptyBlock
  end
end
