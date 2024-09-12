# Retrive hardware details; boardmanufacturer is deprecated:
# https://puppet.com/docs/puppet/6.5/core_facts.html#boardmanufacturer

def read_line_if_exists f
  if FileTest.exist?(f)
    File.read(f).strip
  end
end

keys = [
  :product_name,
  :product_uuid,
  :chassis_serial,
  :product_version,
  :chassis_vendor,
  :modalias,
  :chassis_version,
  :bios_date,
  :bios_version,
  :product_serial,
  :sys_vendor,
  :bios_vendor,
  :uevent,
  :chassis_asset_tag,
  :chassis_type,
]

Facter.add(:hardware) do
  confine :kernel => :linux

  setcode do
    d = {}

    keys.map do |k|

      v = read_line_if_exists "/sys/class/dmi/id/#{k}"
      d[k] = case v
             when /\A[0-9]+\z/
               Integer(v, 10)
             when /\A[0-9]+\.[0-9]+\z/
               Float(v)
             else
               v
             end
    end

    d = d.reject do |_, v|
      v.nil? || (v.is_a?(String) && v.empty?)
    end
  end
end
