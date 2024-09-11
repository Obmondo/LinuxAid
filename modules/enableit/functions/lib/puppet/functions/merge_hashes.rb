# Merge an array of hashes, filtering undef values first
Puppet::Functions.create_function(:merge_hashes) do
  dispatch :merge_hashes do
    required_repeated_param 'Array[Optional[Hash]]', :hashes
    return_type 'Hash'
  end

  def merge_hashes(hashes)
    (hashes.reject &:nil?).reduce({}) do |acc, hash|
      acc.merge hash
    end
  end
end
