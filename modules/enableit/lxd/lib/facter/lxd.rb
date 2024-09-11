# Check if user has set any confile
require 'json'

def lxd
  lxd = Hash.new
  if Facter.value(:lxdrunning) == true
    list=%x{lxc list --format json -c s}
    lxc_list = JSON.parse(list)
    lxc_list.each do |lxc|
      lxd[lxc['name']] = lxc['status']
    end
  end
  return lxd
end

Facter.add("lxd_instance_running") do
  confine :kernel => :linux
  setcode do
    running = Hash.new
    lxd_running = lxd
    lxd_running.each do |key, value |
      running[key] = value == "Running"
    end
    running
  end
end

Facter.add("lxd_instance_stopped") do
  confine :kernel => :linux
  setcode do
    stopped = Hash.new
    lxd_running = lxd
    lxd_running.each do |key, value |
      stopped[key] = value == "STOPPED"
    end
    stopped
  end
end

Facter.add("is_lxdguest") do
  confine :kernel => :linux
  setcode do
    begin
      env = open('/proc/1/environ').read.split("\0").grep(/^container=/)[0]
    rescue Errno::ENOENT, Errno::EACCES
      env = nil
    end

    unless env.nil?
      container = env.split('=')[1]
      container == 'lxc'
    end

  end
end
