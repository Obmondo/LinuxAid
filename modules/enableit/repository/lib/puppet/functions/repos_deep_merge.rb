# lets merge all the values from both the merges, except the array
# since we want to allow dist to be overwriten by the user.
Puppet::Functions.create_function(:repos_deep_merge) do
  dispatch :deep_merge do
    param 'Hash', :hash1
    param 'Hash', :hash2
  end

  def deep_merge(hash1, hash2)
    merged = hash1.dup

    hash2.each do |key, value|
      if merged[key].is_a?(Hash) && value.is_a?(Hash)
        merged[key] = deep_merge(merged[key], value)
      else
        merged[key] = value.is_a?(Array) ? value : value
      end
    end

    merged
  end
end
