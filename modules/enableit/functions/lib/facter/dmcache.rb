Facter.add('is_dmcache') do
  confine :kernel => :linux
  confine :virtual => :physical

  setcode do
    lambda {
      begin
        x = `dmsetup status 2>/dev/null`
        return if $?.exitstatus != 0

        # Match the following format:
        # >> vg_jaina-local: 0 3408953344 cache 8 4377/524288 128 1460096/1460096 9124416 8452889 245665983 18318430 62445 62445 1875 1 writeback 2 migration_threshold 2048 smq 0 rw -

        m = x.match /(?<name>[^:]+):\s+\d+\s+\d+\s+(?<type>[^\s]+)/
        return false if not m

        return m['type'] == 'cache'
      rescue Errno::ENOENT => _ex
        return false
      end
    }.call
  end
end
