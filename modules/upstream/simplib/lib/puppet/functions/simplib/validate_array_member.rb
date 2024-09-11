# Validate that an single input is a member of another `Array` or an
# `Array` input is a subset of another `Array`.
#
# * The comparison can optionally ignore the case of `String` elements.
# * Terminates catalog compilation if validation fails.
#
Puppet::Functions.create_function(:'simplib::validate_array_member') do

  local_types do
    type 'SimpleTypes = Variant[String,Numeric,Boolean]'
  end

  # @param input Input to find within the target
  # @param target
  # @param modifier Modification to be made to the comparison
  #   operation.  Currently, 'i', string case invariance is the only
  #   supported modifier.
  # @return [Nil]
  # @raise [RuntimeError] if validation fails
  #
  # @example Validating single input
  #
  #   validate_array_member('foo',['foo','bar'])     # succeeds
  #   validate_array_member('foo',['FOO','BAR'])     # fails
  #   validate_array_member('foo',['FOO','BAR'],'i') # succeeds
  #
  # @example Validating array input
  #
  #   validate_array_member(['foo','bar'],['foo','bar','baz'])      # succeeds
  #   validate_array_member(['foo','bar'],['FOO','BAR','BAZ'])      # fails
  #   validate_array_member(['foo','bar'],['FOO','BAR','BAZ'], 'i') # succeeds
  #
  dispatch :validate_array_member do
    required_param 'Variant[SimpleTypes,Array[SimpleTypes]]',:input
    required_param 'Array[SimpleTypes]',:target
    optional_param "Enum['i']", :modifier
  end

  def validate_array_member(input, target, modifier=nil)
    to_compare = Array(input).dup
    target_array = target.dup

    if modifier
      if modifier == 'i'
        to_compare.map!{ |x|
         if x.is_a?(String)
           x.downcase
         else
           x
         end
        }

        target_array.map!{ |x|
         if x.is_a?(String)
           x.downcase
         else
           x
         end
        }
      end
    end

    unless (to_compare - target_array).empty?
      fail("simplib::validate_array_member(): '#{target}' does not contain '#{input}'")
    end

  end

end
