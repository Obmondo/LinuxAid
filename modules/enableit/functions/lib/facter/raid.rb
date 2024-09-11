# frozen_string_literal: true

# Parse RAID controller output and return it as a structured fact.

hpssa_logical_re = /^logicaldrive (?<index>\d+) \((?<size>\S+ \w+), (?<type>[^,]+), (?<state>\w+)\)$/
hpssa_disk_re = /^(?<type>\S+) \S+ \(port (?<port>\w+):box (?<box>\w+):bay (?<bay>\w+), (?<interface>[^,]+), (?<size>\d+(\.\d+)? \D+), (?<state>\w+)\)$/

hpssacli = Facter::Core::Execution.which('hpssacli')
Facter.add(:raid) do
  confine :kernel => :linux
  confine { hpssacli }

  # Sample input:
  # $ hpssacli ctrl all show config
  #
  #   Smart Array P440ar in Slot 0 (Embedded)   (sn: PDNLH0BRH8N0S4)
  #
  #
  #      Port Name: 1I
  #
  #      Port Name: 2I
  #
  #      Internal Drive Cage at Port 1I, Box 3, OK
  #
  #      Internal Drive Cage at Port 2I, Box 0, OK
  #      array A (SAS, Unused Space: 0  MB)
  #
  #
  #         logicaldrive 1 (558.9 GB, RAID 1adm, OK)
  #
  #         physicaldrive 1I:3:1 (port 1I:box 3:bay 1, SAS, 600 GB, OK)
  #         physicaldrive 1I:3:2 (port 1I:box 3:bay 2, SAS, 600 GB, OK)
  #         physicaldrive 1I:3:3 (port 1I:box 3:bay 3, SAS, 600 GB, OK)
  #
  #      array B (Solid State SATA, Unused Space: 0  MB)
  #
  #
  #         logicaldrive 2 (745.2 GB, RAID 0, OK)
  #
  #         physicaldrive 1I:3:4 (port 1I:box 3:bay 4, Solid State SATA, 800 GB, OK)
  #

  setcode do
    input = Facter::Util::Resolution
            .exec('hpssacli ctrl all show config')

    # Steps:
    # + split arrays
    # + remove whitespace
    # + remove header
    # + group them into twos so we get both the match itself and the contents
    #   until next match
    # + convert enumerator to array
    input
      .split(/^(\s+array [A-Z]+)/)
      .map(&:strip)
      .drop(1)
      .each_slice(2)
      .to_a
      .reduce({}) do |acc, (idx, value)|
      device = '/dev/sd' + idx.match(/\S+$/)[0].downcase

      # split on double newlines and strip whitespace
      (_interface, logical, physical) = value.split(/\n\n/).map(&:strip)
      m = hpssa_logical_re.match(logical)
      raise ArgumentError, "could not match logicaldrive '#{logical}'" unless m

      details = m.names.zip(m.captures).to_h

      *disks = physical.split(/\n/).map(&:strip).map do |disk|
        m = hpssa_disk_re.match(disk)
        raise ArgumentError, "could not match physicaldrive '#{disk}'" unless m

        disk_details = m.names.zip(m.captures).to_h
        disk_details.merge(
          'bay' => disk_details['bay'].to_i,
          'box' => disk_details['box'].to_i,
          'index' => disk_details['index'].to_i,
          'state' => disk_details['state'].downcase.to_sym,
          'type' => disk_details['type'].downcase.to_sym,
        )
      end

      details['disks'] = disks
      acc[device] = details.merge(
        'index' => details['index'].to_i,
        'state' => details['state'].downcase.to_sym,
      )
      acc
    end
  end
end
