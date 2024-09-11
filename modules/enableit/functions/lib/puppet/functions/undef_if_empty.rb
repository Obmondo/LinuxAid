# frozen_string_literal: true

Puppet::Functions.create_function(:undef_if_empty) do
  dispatch :undef_if_empty do
    param 'Variant[Hash,Array]', :arg
  end

  def undef_if_empty(xs)
    values = case xs
             when Hash
               xs.values
             else
               xs
             end

    return nil if values.empty?

    xs
  end
end
