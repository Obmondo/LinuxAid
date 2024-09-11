Puppet::Functions.create_function(:lvm_dmpath) do
  dispatch :lvm_dmpath do
    param 'String', :vg_name
    param 'String', :lv_name
  end

  def lvm_dmpath(vg, lv)
    escaped_lv = lv.gsub(/-/, '--')
    "/dev/mapper/#{vg}-#{escaped_lv}"
  end
end
