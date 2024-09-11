# frozen_string_literal: true

def array_merge(arrays)
  {}.merge(*arrays.compact)
end
