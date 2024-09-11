module WildflyCliAssembler
  def assemble_address(resource)
    address = []

    escaped_slash = '__ESCAPED__'
    escaped_resource = resource.gsub(%r{\\\/}, escaped_slash)

    escaped_resource.split('/').each do |token|
      node_type, node_name = token.split('=')
      unless node_type.nil? && node_name.nil?
        address << { node_type => (node_name.nil? ? nil : node_name.gsub(escaped_slash, '/')) }
      end
    end

    address
  end

  def assemble_attributes(params)
    attributes = {}

    params.split(',').each do |token|
      attribute, value = token.split('=')
      attributes[attribute.strip] = value.strip
    end

    attributes
  end

  def assemble_command(command)
    if command.include? ':'
      path, operation = command.split(':')
    else
      path = '/'
      operation = command
    end

    command = {
      :address => assemble_address(path)
    }

    command.merge assemble_operation(operation)
  end

  def assemble_operation(operation)
    operation.sub!('()', '')

    if operation =~ /^([\w\-]+)$/
      operation_name = Regexp.last_match(1)
    end

    if operation =~ /([\w\-]+)\s+([\w\-]+)/
      operation_name = Regexp.last_match(1)
      attribute_name = Regexp.last_match(2)
    end

    if operation =~ /([\w\-]+)\((.+)\)/
      operation_name = Regexp.last_match(1)
      params = Regexp.last_match(2)
    end

    assembled_operation = { :operation => operation_name }

    unless attribute_name.nil?
      assembled_operation[:name] = attribute_name
    end

    unless params.nil?
      assembled_operation.merge! assemble_attributes(params)
    end

    assembled_operation
  end
end
