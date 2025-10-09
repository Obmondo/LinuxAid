# frozen_string_literal: true

Puppet::Functions.create_function(:'haproxy::sort_bind') do
  dispatch :sort_bind do
    param 'Hash', :bind
    return_type 'Array'
  end

  def sort_bind(bind)
    bind.sort_by do |address_port|
      md = %r{^((\d+)\.(\d+)\.(\d+)\.(\d+))?(.*)}.match(address_port[0])
      [(md[1] ? md[2..5].reduce(0) { |addr, octet| (addr << 8) + octet.to_i } : -1), md[6]]
    end
  end
end
