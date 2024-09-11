# frozen_string_literal: true

COERCE_MAP = {
  'src_port' => Integer,
  'dst_port' => Integer,
}

Puppet::Functions.create_function(:docker_port_details) do
  dispatch :docker_port_details do
    param 'Pattern[/^(\d+\.\d+\.\d+\.\d+:)?\d+:\d+(\/(tcp|udp))?$/]', :port
  end

  def docker_port_details(port)
    m = port.match %r{^((?<bind>(\d+\.\d+\.\d+\.\d+)):)?(?<src_port>\d+):(?<dst_port>\d+)(/(?<protocol>(tcp|udp)))?$}
    m.names
      .zip(m.captures)
      .to_h
      .reduce({}) { |acc, (k, v)|
      f = COERCE_MAP[k]
      acc[k] = case f
               when nil
                 v
               when Class
                 f.class_eval(v)
               when Proc
                 f.call(v)
               end

      acc
    }
  end
end
