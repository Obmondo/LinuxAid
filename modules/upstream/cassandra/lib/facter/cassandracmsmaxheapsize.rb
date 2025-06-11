# Returns a value (MB) that might be suitable to set the MAX_HEAP_SIZE when using
# the Concurrent Mark Sweep (CMS) Collector.
# See [Tuning Java resources]
# (https://docs.datastax.com/en/cassandra/2.1/cassandra/operations/ops_tune_jvm_c.html)
# for more details.
#
# @return [integer] max(min(1/2 ram, 1024), min(1/4 ram, 14336))
# @see cassandracmsheapnewsize
# @see cassandraheapnewsize
# @see cassandramaxheapsize
Facter.add('cassandracmsmaxheapsize') do
  setcode do
    memorysize_mb = Facter.value(:memorysize_mb).to_f
    calc1 = [memorysize_mb * 0.5, 1024].min
    calc2 = [memorysize_mb * 0.25, 14_336].min
    maxheapsize = [calc1, calc2].max
    maxheapsize.round
  end
end
