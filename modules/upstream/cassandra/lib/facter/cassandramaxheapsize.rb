# Returns a value (MB) that might be suitable to set the MAX_HEAP_SIZE.
# See [Tuning Java resources]
# (https://docs.datastax.com/en/cassandra/2.1/cassandra/operations/ops_tune_jvm_c.html)
# for more details.
#
# @return [integer] max(min(1/2 ram, 1024), min(1/4 ram, 8192))
# @see cassandracmsheapnewsize
# @see cassandracmsmaxheapsize
# @see cassandraheapnewsize
Facter.add('cassandramaxheapsize') do
  setcode do
    memorysize_mb = Facter.value(:memorysize_mb).to_f
    calc1 = [memorysize_mb * 0.5, 1024].min
    calc2 = [memorysize_mb * 0.25, 8192].min
    maxheapsize = [calc1, calc2].max
    maxheapsize.round
  end
end
