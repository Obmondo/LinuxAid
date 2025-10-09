Puppet::Type.newtype(:wildfly_restart) do
  desc 'Manage JBoss restarts.'

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
    desc 'Management port. Defaults to 9990'
    defaultto 9990
  end

  newparam(:retries) do
    desc 'Number of times it will check if server is running after a restart'
    defaultto 3

    munge(&:to_i)
  end

  newparam(:wait) do
    desc 'Amount of time (in seconds) that it will wait before next attempt'
    defaultto 10

    munge(&:to_i)
  end

  newparam(:reload) do
    desc 'Whether the server should only reload instead of restarting.'
    defaultto false
  end

  newproperty(:pending) do
    desc 'Whether the restart should be executed or not'

    defaultto true

    def retrieve
      !provider.pending?
    end

    def sync
      provider.restart
    end
  end
end
