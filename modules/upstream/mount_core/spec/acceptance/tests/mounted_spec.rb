require 'spec_helper_acceptance'

require 'mount_utils'

RSpec.context 'when managing mounts' do
  agents.each do |agent|
    context "on #{agent}" do
      include_context('mount context', agent)

      it 'creates an entry in the filesystem table and mounts it' do
        step '(setup) create mount point'
        on(agent, "mkdir /#{name}", acceptable_exit_codes: [0, 1])

        step '(setup) create new filesystem to be mounted'
        MountUtils.create_filesystem(agent, name)

        step 'create a mount with puppet (mounted)'
        args = if agent['platform'] =~ %r{aix}
                 ['ensure=mounted',
                  "fstype=#{fs_type}",
                  "options='log=/dev/hd8'",
                  "device=/dev/#{name}"]
               else
                 ['ensure=mounted',
                  "fstype=#{fs_type}",
                  'options=loop',
                  "device=/tmp/#{name}"]
               end
        on(agent, puppet_resource('mount', "/#{name}", args))

        step 'verify entry in filesystem table'
        on(agent, "cat #{fs_file}") do |result|
          fail_test "didn't find the mount #{name}" unless result.stdout.include?(name)
        end

        step 'verify entry is mounted'
        on(agent, 'mount') do |result|
          fail_test "didn't find the mount #{name} mounted" unless result.stdout.include?(name)
        end
      end
    end
  end
end
