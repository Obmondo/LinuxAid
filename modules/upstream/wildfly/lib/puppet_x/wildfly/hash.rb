class Hash
  def deep_stringify_values
    deep_transform_values(&:to_s)
  end

  def deep_obfuscate_sensitive_values
    _deep_transform_values_in_object(self, true, &:to_s)
  end

  def deep_transform_values(&block)
    _deep_transform_values_in_object(self, false, &block)
  end

  def _deep_transform_values_in_object(object, obfuscate, &block)
    case object
    when Hash
      object.each_with_object({}) do |(key, value), result|
        actual_block = obfuscate && key.to_s.include?('password') ? proc { |_| '******' } : block
        result[key] = _deep_transform_values_in_object(value, obfuscate, &actual_block)
      end
    when Array
      object.map { |e| _deep_transform_values_in_object(e, obfuscate, &block) }.sort
    else
      yield(object)
    end
  end

  # Return a hash containing the keys of this hash that are also present in the other hash
  def deep_intersect(other)
    diff = {}

    each do |key, value|
      next if other[key].nil?
      if value.is_a? Hash
        diff[key] = value.deep_intersect(other[key])
      elsif other.keys.include? key
        diff[key] = value
      end
    end

    diff
  end

  def insync?(other)
    other.deep_intersect(self).deep_stringify_values == deep_stringify_values
  end
end
