# -*- mode: ruby -*-
# vi: set ft=ruby :
# Time-stamp: <Sat 2019-02-02 00:46 svarrette>
###########################################################################################
#              __     __                          _    __ _ _
#              \ \   / /_ _  __ _ _ __ __ _ _ __ | |_ / _(_) | ___
#               \ \ / / _` |/ _` | '__/ _` | '_ \| __| |_| | |/ _ \
#                \ V / (_| | (_| | | | (_| | | | | |_|  _| | |  __/
#                 \_/ \__,_|\__, |_|  \__,_|_| |_|\__|_| |_|_|\___|
#                           |___/
###########################################################################################
require 'yaml'
require 'ipaddr'
# require 'deep_merge'
require 'pp'
require 'erb'

###### Expected Vagrant plugins detection ######
# For more information on the below plugins:
# - https://github.com/oscar-stack/vagrant-hosts
# - https://github.com/dotless-de/vagrant-vbguest
# - https://github.com/emyl/vagrant-triggers
# - https://github.com/fgrehm/vagrant-cachier
# - https://github.com/jantman/vagrant-r10k
# Terminal-table is a nice ruby gem for automatically print tables with nice layout
###
[ 'vagrant-hosts',
  'vagrant-vbguest',
  #  'vagrant-triggers',
  'vagrant-cachier',
  'puppet',
  'terminal-table'
].each do |plugin|
  abort "Install the  '#{plugin}' plugin with 'vagrant plugin install #{plugin}'" unless Vagrant.has_plugin?("#{plugin}")
end
require 'terminal-table'

### Plugin for Windows ###
require 'win32/process' if Vagrant::Util::Platform.windows?
require 'win32/dir' if Vagrant::Util::Platform.windows?
require 'win32/service' if Vagrant::Util::Platform.windows?

### Global variables ###
# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"


TOP_SRCDIR     = File.expand_path File.dirname(__FILE__)
TOP_CONFDIR    = File.join(TOP_SRCDIR, 'tests', 'vagrant')
TOP_PUPPET_DIR = File.join(TOP_CONFDIR, 'puppet')
SCRIPTDIR      = File.join(TOP_CONFDIR, 'scripts')
config_file    = File.join(TOP_CONFDIR, 'config.yaml')

### Default settings ###
DEFAULT_SETTINGS = {
  # Default images settings
  :defaults => {
    :os     => :centos7,
    :ram    => 512,
    :vcpus  => 2,
    :vbguest_auto_update => true,
    :role   => 'default',
    :nnodes => 2,          # Number of computing nodes
  },
  # Default domain settings
  :network => {
    :domain => 'vagrant.dev',
    :range  => '10.10.1.0/24',
  },
  # Default Boxes
  :boxes => {
    :centos7  => 'centos/7',
    :debian8  => 'debian/contrib-jessie64',
    :ubuntu14 => 'ubuntu/trusty64'
  },
  # Characteristics of the virtual computing nodes, from slurm point of view
  :nodes => {
    :cpus             => 2,
    :sockets          => 1,
    :ram              => 512,
    :realmemory       => 400,
    :cores_per_socket => 2,
    :thread_per_core  => 1,
    :state            => 'UNKNOWN'
  },

  # General Slurm Settings
  :slurm => {
    :clustername    => 'thor',
    :partitions => {
      'DEFAULT'=> {
        :content => 'State=UP AllowGroups=clusterusers AllowAccounts=ALL DisableRootJobs=YES OverSubscribe=NO',
      },
      'admin' => {
        :priority => 100,
        :content  => "Hidden=YES DefaultTime=0-10:00:00 MaxTime=5-00:00:00 MaxNodes=UNLIMITED  AllowQos=qos-admin",
      },
      'interactive' => {
        :nodes    => 1,
        :priority => 20,
        :content  => 'DefaultTime=0-1:00:00  MaxTime=0-4:00:00  AllowQos=qos-besteffort,qos-interactive',
      },
      'batch' => {
        :nodes => 2,
        :priority => 20,
        :content => 'DefaultTime=0-2:00:00  MaxTime=5-00:00:00 MaxNodes=UNLIMITED Default=YES AllowQos=qos-besteffort,qos-batch'
      },
    },
  },
  # virtual images to deploy
  # <name>:
  #   :hostname: <hostname>
  #   :desc: <VM-description>
  #   :os: <os>       # from the configured boxes
  #   :ram: <ram>
  #   :vcpus: <vcpus>
  #   :role: <role>   # supported: [ 'XX', 'YY' ]
  :vms => {
    # Slurm controller (primary)
    # /!\ SHOULD BE the first entry
    'slurm-master' => {
      :ram => 2048, :vcpus => 2, :desc => "Slurm Controller #1 (primary)",
      :role => 'controller'
    },
    # 'slurm-db' => {
    #   :ram => 1024, :vcpus => 1, :desc => "Slurm Database",
    #   :role => 'db'
    # },
    'access' => {
      :hostname => 'access', :ram => 1024, :vcpus => 1, :desc => "Cluster frontend",
      :role => 'login'
    },
    #  /!\ Computing nodes are added afterwards depending on the number of nodes / partitions to test.
  },
}

# List of default provisioning scripts
DEFAULT_PROVISIONING_SCRIPTS = [
  "#{SCRIPTDIR}/bootstrap.sh",
  "#{SCRIPTDIR}/puppet_modules_setup.rb",
  "#{SCRIPTDIR}/setup_testing_users_groups.sh"
]

begin
  gem "puppet"
rescue Gem::LoadError
  raise "puppet is not installed in vagrant gems! please run 'vagrant plugin install puppet'"
end

# Load the settings (eventually overwritten using values from the yaml file 'config.yaml')
settings = DEFAULT_SETTINGS.clone
if File.exist?(config_file)
  config = YAML::load_file config_file
  settings.deep_merge!( config ) if config
end
abort "Undefined settings" if settings.nil?

# puts settings.to_yaml
# exit 0


############################################################
# Complete configuration of the boxes to deploy
defaults   = settings[:defaults]
network    = settings[:network]
slurm      = settings[:slurm]
nodes      = settings[:nodes]
puppet_dir = File.join('tests', 'vagrant', 'puppet') # Local puppet directory

controller_vm = settings[:vms].select { |k,v| v[:role].include?('controller')}.keys.first
login_vm      = settings[:vms].select { |k,v| v[:role].include?('login')}.keys.first
db_vm         = settings[:vms].select { |k,v| v[:role].include?('db')}.keys.first

# pp "controller: #{controller_vm}"
# pp "login: #{login_vm}"
# pp "DB: #{db_vm} - "

# Complete settings with the appropriate number of computing nodes
num_nodes = default_num_nodes = defaults[:nnodes] ? defaults[:nnodes] : 1
(1..num_nodes).each do |n|
  settings[:vms]["node-#{n}"] = {
    :ram   => nodes[:ram],
    :vcpus => nodes[:cpus],
    :desc  => "Computing Node \##{n}",
    :role  => 'node',
  } unless settings[:vms]["node#{n}"]
end
#pp settings

###   network settings
ipaddr   = IPAddr.new network[:range]
ip_range = ipaddr.to_range.to_a
ip_index = {
  :login      => 2,
  :controller => 11,
  :db         => 15,
  :node       => 101
}

# Complete Slurm settings and generate the hiera locals accordingly
unless controller_vm.nil?
  slurm[:controlmachine] = controller_vm
  slurm[:controladdr]    = ip_range[ ip_index[:controller].to_i ].to_s
end
if db_vm.nil?
  slurm[:accountingstoragehost] = controller_vm
else
  slurm[:accountingstoragehost] = db_vm
end

hiera_locals_yaml = File.join(TOP_PUPPET_DIR, 'hieradata', 'locals.yaml')
hiera_locals_erb = %Q{
# Local Hiera values for Puppet Slurm
---
slurm::clustername: '<%= slurm[:clustername] %>'
slurm::controlmachine: '<%= slurm[:controlmachine] %>'
slurm::controladdr: '<%= slurm[:controladdr] %>'
slurm::accountingstoragehost: '<%= slurm[:accountingstoragehost] %>'

############
slurm::nodes:
  'node-[1-<%= num_nodes %>]':
    comment: 'COMPUTE NODES'
    content: 'CPUs=<%= nodes[:cpus] %>  Sockets=<%= nodes[:sockets] %> CoresPerSocket=<%= nodes[:cores_per_socket] %> ThreadsPerCore=<%= nodes[:thread_per_core] %>  RealMemory=<%= nodes[:realmemory] %> State=<%=  nodes[:state] %>'

##################
slurm::partitions:
<% index=1 %>
<% slurm[:partitions].each_with_index do |(name, v), i| %>
<% if index <= (num_nodes > 0 ? num_nodes : 1) %>
  '<%= name %>':
<%  if v[:priority] %>
    priority: <%= v[:priority] %>
<%  end %>
<%  if name == 'admin' %>
<%     if num_nodes > 1 %>
    nodes: 'node-[1-<%= num_nodes %>]'
<%     else %>
    nodes: 'node-1'
<%     end %>
<%  end %>
<%  if v[:nodes] %>
<%     if v[:nodes] > 1 %>
    nodes: 'node-[<%= index %>-<%= (index + v[:nodes] <= num_nodes) ? index + v[:nodes] : num_nodes %>]'
<%     else %>
    nodes: 'node-<%= index %>'
<%     end %>
<%    index = index + v[:nodes] %>
<%  end %>
<%  if v[:content] %>
<%    content = v[:content] %>
<%    content << " DefMemPerCPU=#{nodes[:realmemory]} MaxMemPerCPU=#{nodes[:realmemory]}" unless [ 'DEFAULT', 'admin'].include?( name ) %>
    content: <%= content %>
<%  end %>
<%  end %>
<% end %>
}

if [ 'up', 'provision' ].include?(ARGV[0])
  #unless File.exists?(hiera_locals_yaml)
  content = ERB.new(hiera_locals_erb, nil, '<>').result(binding)
  puts "==> generating hieradata/#{File.basename(hiera_locals_yaml)}"
  File.open(hiera_locals_yaml.to_s, "w+") do |f|
    f.write content
  end
end


############################################################
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  ### Common configs shared by all VMs ###
  # Cache plugin -- Supports local cache, so you don't wast bandwitdh
  # vagrant plugin install vagrant-cachier   # see https://github.com/fgrehm/vagrant-cachier
  config.cache.auto_detect = true if Vagrant.has_plugin?("vagrant-cachier")

  # check if VirtualBox Guest Additions are up to date
  if Vagrant.has_plugin?("vagrant-vbguest")
    # set auto_update to false, if you do NOT want to check the correct
    # additions version when booting these boxes
    config.vbguest.auto_update = defaults[:vbguest_auto_update]
  end

  # Shell provisioner, to setup minimal conditions for Puppet provisioning
  DEFAULT_PROVISIONING_SCRIPTS.each do |script|
    config.vm.provision "shell", path: "#{script}", keep_color: true
  end
  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"
  config.vm.synced_folder "#{puppet_dir}/hieradata", "/tmp/vagrant-puppet/hieradata", type: "virtualbox"

  ##pp ip_range

  # cosmetics for the post-up message
  __table = {
    :title    => "Puppet Testing infrastructure deployed on Vagrant",
    :headings => [ 'Name', 'Hostname', 'OS', 'vCPU/RAM', 'Role', 'Description', 'IP' ],
    :rows => [],
  }

  #__________________________________
  settings[:vms].each do |name, node|
    hostname = node[:hostname] ? node[:hostname] : name
    domain   = network[:domain]
    fqdn     =    "#{hostname}.#{domain}"
    boxname  =  defaults[:os].to_s.downcase.gsub(/([^\d]+)(\d+)/, '\\1-\\2')
    name     = boxname if name == 'default'
    os       =    node[:os]       ? node[:os].to_sym : defaults[:os].to_sym
    ram      =    node[:ram]      ? node[:ram]       : defaults[:ram]
    vcpus    =    node[:vcpus]    ? node[:vcpus]     : defaults[:vcpus]
    role     =    node[:role]     ? node[:role]      : 'default'
    desc     =    node[:desc]     ? node[:desc]      : 'n/a'

    abort "Non-existing box OS '#{os}' for the VM '#{name}'" if  settings[:boxes][os.to_sym].nil?
    abort "Empty IP address range" if ip_range.empty?
    abort "Unknown role '#{role}' for the VM '#{name}'" unless ip_index[role.to_sym]
    ip = ip_range[ ip_index[role.to_sym].to_i ].to_s
    ip_index[role.to_sym] += 1   # increment index for the next VM of this type

    # ip = ip_range[ network[:ip_offset].to_i ].to_s

    config.vm.define "#{name}" do |c|
      c.vm.box      = settings[:boxes][os.to_sym]
      c.vm.hostname = "#{fqdn}"
      c.vm.network :private_network, :ip => ip
      c.vm.provision :hosts, :sync_hosts => true, :add_localhost_hostnames => false
      c.vm.provider "virtualbox" do |v|
        v.customize [ 'modifyvm', :id, '--name', hostname, '--memory', ram.to_s ]
        v.customize [ 'modifyvm', :id, '--cpus', vcpus.to_s ] if vcpus.to_i > 1
      end


      # Prepare custom global role fact for this VM
      c.vm.provision "shell",
                     inline: "echo '{ \"role\": \"#{role}\" }' > /opt/puppetlabs/facter/facts.d/custom.json",
                     keep_color: true
      ################ Puppet install ##############
      c.vm.provision "puppet" do |puppet|
        puppet.options = [
          '--verbose',
          '-t',
          # '--debug',
          "--yamldir /vagrant/#{puppet_dir}/hieradata",
        ]
        # Does not work :(
        # puppet.facter = { "role" => "#{role}" }
        # Setup hiera
        #puppet.working_directory = File.join('/vagrant', "#{puppet_dir}")
        puppet.hiera_config_path = "#{puppet_dir}/hiera.yaml"
        puppet.module_path       = [ "#{puppet_dir}/site", "#{puppet_dir}/modules" ]
        puppet.manifests_path    = "#{puppet_dir}/manifests"
        puppet.manifest_file     = File.exists?(File.join(TOP_PUPPET_DIR, 'manifests', "#{role}.pp")) ? "#{role}.pp" : 'default.pp'
      end

      ### Custom controler setup
      if role == 'controller'
        # create cluster and qos
        c.vm.provision "shell" do |s|
          s.inline = "echo '=> Add cluster #{slurm[:clustername]} in accounting database (if not yet done)'\n"
          saccrmgr_cmd = "sacctmgr -i add cluster #{slurm[:clustername]}"
          s.inline << "echo '    - running: #{saccrmgr_cmd}'\n"
          s.inline << "#{saccrmgr_cmd}\n"
          s.inline << "echo '=> setup QOS based on partitions configuration'\n"
          saccrmgr_qos_cmd = 'sacctmgr -i add qos qos-besteffort Priority=0 flags=NoReserve'
          s.inline << "echo '    - running: #{saccrmgr_qos_cmd}'\n"
          s.inline << "#{saccrmgr_qos_cmd}\n"
          slurm[:partitions].each do |p,v|
            next if p == 'DEFAULT'
            priority = v[:priority] ? v[:priority] : 0
            saccrmgr_qos_cmd = "sacctmgr -i add qos qos-#{p} Priority=#{priority} "
            saccrmgr_qos_cmd << "Preempt=#{v[:preempt]} " if v[:preempt]
            #saccrmgr_qos_cmd << "GrpNodes=#{v[:nodes]} "
            #saccrmgr_qos_cmd << "flags=#{v[:flags]} "     if v[:flags]
            s.inline << "echo '    - running: #{saccrmgr_qos_cmd}'\n"
            s.inline << "#{saccrmgr_qos_cmd}\n"
          end
          s.inline << "systemctl restart slurmctld"   # Expect to end with exit code 0
        end
        # create account and sample users associated to it
        c.vm.provision "shell", keep_color: true,
                       path: "#{SCRIPTDIR}/setup_slurm_accounting.sh",
                       args: [ '--clustername', "#{slurm[:clustername]}"]
      end

      ### Custom login/compute node setup
      if [ 'login', 'node' ].include?( role )
        ## [Un]comment the below part if you want [don't want] an additional shared directory
        c.vm.synced_folder "tests/vagrant/shared", "/shared",
                           mount_options: ['dmode=777','fmode=777'],
                           type: "virtualbox" # Shared directory for users
      end

      __table[:rows] << [ name, fqdn, os.to_sym, "#{vcpus}/#{ram}", role, desc, ip]

      if settings[:vms].keys.last == name
        c.trigger.after :up do |trigger|
          trigger.info = (Terminal::Table.new __table).to_s
          trigger.warn = <<-EOF
- Virtual Puppet Testing infrastructure deployed deployed!
EOF
        end
      end

    end
  end

  # config.trigger.after :up do
  # puts Terminal::Table.new __table
  # end
end
