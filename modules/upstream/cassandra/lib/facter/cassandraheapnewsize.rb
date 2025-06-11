# Returns a value (MB) that might be suitable to set the HEAP_NEWSIZE.
# See [Tuning Java resources]
# (https://docs.datastax.com/en/cassandra/2.1/cassandra/operations/ops_tune_jvm_c.html)
# for more details.
#
# @return [integer] min(100 times the number of cores, 1/4 MAX_HEAP_SIZE)
# @see cassandracmsheapnewsize
# @see cassandracmsmaxheapsize
# @see cassandramaxheapsize
Facter.add('cassandraheapnewsize') do
  setcode do
    maxheapsize = Facter.value(:cassandramaxheapsize).to_f
    processorcount = Facter.value(:processorcount).to_f
    heapnewsize = [100 * processorcount, maxheapsize * 0.25].min
    heapnewsize.round
  end
end
