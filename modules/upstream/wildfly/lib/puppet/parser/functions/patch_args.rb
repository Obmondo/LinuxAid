module Puppet::Parser::Functions
  newfunction(:patch_args, :type => :rvalue) do |args|
    source = args[0]
    override_all = args[1]
    override = args[2]
    preserve = args[3]

    params = []
    params << source

    if override_all
      params << '--override-all'
    else
      params << "--override=#{override.join(',')}" unless override.empty?
      params << "--preserve=#{preserve.join(',')}" unless preserve.empty?
    end

    params.join(' ')
  end
end
