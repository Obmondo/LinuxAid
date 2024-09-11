Puppet::Type.newtype(:wildfly_reload) do
  @doc = 'Manage JBoss reloads.'

  newparam(:name, :namevar => true) do
    desc 'Informational name'
  end

  newparam(:username) do
    desc 'JBoss Management User'
  end

  newparam(:password) do
    desc 'JBoss Management User Password'
  end

  newparam(:host) do
    desc 'Host of Management API. Defaults to 127.0.0.1'
    defaultto '127.0.0.1'
  end

  newparam(:port) do
    desc 'Management port. Defaults to 127.0.0.1'
    defaultto 9990
  end

  newparam(:retries) do
    desc 'Number of times it will check if server is running after a reload'
    defaultto 3
  end

  newparam(:wait) do
    desc 'Amount of time (in seconds) that it will wait before next attempt'
    defaultto 10
  end

  newproperty(:pending) do
    desc 'Whether the reload should be executed or not'

    defaultto true

    def retrieve
      !provider.is_pending?
    end

    def sync
      provider.reload
    end
  end

  autorequire(:service) do
    ['wildfly']
  end
end
