def coerce_type(value)
    # Try to convert values to Integer or nil; if we can't, just return the
    # original value
  begin
    return Integer(value)
  rescue ArgumentError
  end

  if value == ''
    return nil
  end

  return value
end

def array_to_hash(keys, values)
  values = values.map do |value|
    coerce_type(value)
  end

  return Hash[keys.zip(values)]
end

def lvm_names(lv='vgs')
  lvm = Facter::Util::Resolution.exec("#{lv} -o name --noheadings 2>/dev/null")
  lvm_list = lvm.split
end

Facter.add(:lvm) do
  confine :kernel => :linux
  confine :virtual => :physical

  setcode do
    lambda {
      ret = {}
      # check that pvs is in PATH
      %x(which pvs 2>/dev/null)
      if not $?.exitstatus == 0
        return
      end

      # get all available keys
      keys = %x(pvs -o help 2>&1 | grep -E '^   [ ]+' | grep -Ev 'Show help\.$|_all ' | sed -r 's/^ +//' | cut -d ' ' -f 1 | tr '\n' ',' | sed -r 's/,$//' )
      if (not $?.exitstatus == 0)
        STDERR.puts "lvm: unable to get available keys"
        return
      end

      names, *values = %x(pvs --separator '||' -o #{keys}).split("\n")
      if (not $?.exitstatus == 0)
        STDERR.puts "lvm: unable to get values"
        return
      end

      h = {'pvs' => {}}
      values.each do |pv|
        tmp = array_to_hash(keys.split(','), pv.strip.split('||'))
        h['pvs'][tmp['pv_name']] = tmp
      end

      h
    }.call
  end
end

if Facter.value(:lvm_support)
  {'vgs' => 'vg','pvs' => 'pv'}.each do |lvm, lv|
    lvm_names(lvm).each do |name|
      Facter.add("lvm_#{lv}") do
        setcode do
          Hash[name, Hash['size', Facter::Util::Resolution.exec("#{lvm} --units G -o #{lv}_size #{name} --noheadings 2>/dev/null")]]
        end
      end
    end
  end
end
