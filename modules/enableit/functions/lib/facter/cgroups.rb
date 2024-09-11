require "facter"

def in_my_container?(pid)
  begin
    # check output of pid 1 (`cat /proc/1/cgroup | cut -d ":" -f 3`) matches
    # output of pid arg output
    @my_cgroup ||=
      begin
        file = File.new("/proc/1/cgroup", "r")
        line = file.gets # only read 1 line
        file.close
        mycgroup = line.split(":")[2] # third result is the one we want
      end

    file = File.new("/proc/#{pid.delete(' ')}/cgroup", "r")
    line = file.gets            # only read 1 line
    file.close
    cgroup=line.split(":")[2]   # third result is the one we want

    return  cgroup == @my_cgroup
  end
end
