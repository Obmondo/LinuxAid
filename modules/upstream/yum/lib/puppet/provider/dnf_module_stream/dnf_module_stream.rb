# frozen_string_literal: true

Puppet::Type.type(:dnf_module_stream).provide(:dnf_module_stream) do
  desc 'Unique provider'

  confine package_provider: 'dnf'

  commands dnf: 'dnf'

  # Converts plain output from 'dnf module list <Module>' to an array formatted as:
  # {
  #   default_stream: "<Default stream> (if there's one)",
  #   enabled_stream: "<Enabled stream> (if there's one)",
  #   available_streams: ["<Stream>", "<Stream>", ...,]
  # }
  def dnf_output_2_hash(dnf_output)
    module_hash = { available_streams: [] }
    dnf_output.lines.each do |line|
      line.chomp!
      break if line.empty?

      # @stream_start and @stream_length: chunk of dnf output line with stream info
      # Determined in elsif block below from dnf output header
      if !@stream_start.nil?
        # Stream string is '<Stream>', '<Stream> [d][e]', or the like
        stream_string = line[@stream_start, @stream_length].rstrip
        stream = stream_string.split[0]
        module_hash[:default_stream] = stream if stream_string.include?('[d]')
        module_hash[:enabled_stream] = stream if stream_string.include?('[e]')
        module_hash[:available_streams] << stream
      elsif line.split[0] == 'Name'
        # 'dnf module list' output header is 'Name<Spaces>Stream<Spaces>Profiles<Spaces>...'
        # Each field has same position of data that follows
        @stream_start = line[%r{Name\s+}].length
        @stream_length = line[%r{Stream\s+}].length
      end
    end
    module_hash
  end

  # Gets module default, enabled and available streams
  # Output formatted by function dnf_output_2_hash
  def streams_state(module_name)
    # This function can be called multiple times in the same resource call
    return unless @streams_current_state.nil?

    dnf_output = dnf('-q', 'module', 'list', module_name)
  rescue Puppet::ExecutionFailure
    # Assumes any execution error happens because module doesn't exist
    raise ArgumentError, "Module \"#{module_name}\" not found"
  else
    @streams_current_state = dnf_output_2_hash(dnf_output)
  end

  def disable_stream(module_name)
    dnf('-y', 'module', 'reset', module_name)
  end

  def enable_stream(module_name, target_stream)
    action = @streams_current_state.key?(:enabled_stream) ? 'switch-to' : 'enable'
    dnf('-y', 'module', action, "#{module_name}:#{target_stream}")
  end

  def stream
    streams_state(resource[:module])
    case resource[:stream]
    when :absent
      # Act if any stream is enabled
      @streams_current_state.key?(:enabled_stream) ? @streams_current_state[:enabled_stream] : :absent
    when :default
      # Act if default stream isn't enabled
      # Specified stream = :default requires an existing default stream
      raise ArgumentError, "No default stream to enable in module \"#{resource[:module]}\"" unless
        @streams_current_state.key?(:default_stream)

      @streams_current_state[:enabled_stream] == @streams_current_state[:default_stream] ? :default : @streams_current_state[:enabled_stream]
    when :present
      # Act if no stream is enabled
      # Specified stream = :default requires an existing default or enabled stream
      raise ArgumentError, "No default stream to enable in module \"#{resource[:module]}\"" unless
        @streams_current_state.key?(:default_stream) || @streams_current_state.key?(:enabled_stream)

      @streams_current_state.key?(:enabled_stream) ? :present : :absent
    else
      # Act if specified stream isn't enabled
      @streams_current_state[:enabled_stream]
    end
  end

  def stream=(target_stream)
    case target_stream
    when :absent
      disable_stream(resource[:module])
    when :default, :present
      enable_stream(resource[:module], @streams_current_state[:default_stream])
    else
      enable_stream(resource[:module], target_stream)
    end
  end
end
