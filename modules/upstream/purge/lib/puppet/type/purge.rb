require 'puppet'

Puppet::Type.newtype(:purge) do

  attr_reader :purged_resources

  @doc=(<<-EOT)
  This is a metatype to purge resources from the agent.  When run without
  parameters the purge type takes a resource type as a title.  The
  resource type must be one that has a provider that supports the instances
  method (eg: package, user, yumrepo).  Any instances of the resource found
  on the agent that are *not* in the catalog will be purged.

  You can also add filter conditions to control the behaviour of purge
  using the if and unless parameters.

  Eg:
  To remove *all* users found on the system that are not present in the
  catalog (caution!):

   purge { 'user': }

  To remove all users found on the system but not in the catalog, unless
  the user has a UID below 500:

   purge { 'user':
    unless => [ 'uid', '<=', '500' ],
   }
  EOT


  # The ensurable block is mostly to make sure that this resource type
  # will enter a changed state when there are resources that have been
  # purged, that signals to puppet that any refresh events associated
  # with this resource, like notify, should be triggered.
  #
  ensurable do
    defaultto(:purged)
    newvalue(:purgable)
    newvalue(:purged) do
      true
    end

    def retrieve
      if @resource.purged?
        :purgable
      else
        :purged
      end
    end
  end


  # By setting @isomorphic to false Puppet will allow duplicate namevars
  # (not duplicate titles).  This allows for multiple purge resource types
  # to be declared purging the same resource type with different criteria
  #
  @isomorphic = false

  newparam(:resource_type) do
    isnamevar
    desc "Name of the resource type to be purged"
    validate do |name|
      raise ArgumentError, "Unknown resource type #{name}" unless Puppet::Type.type(name)
    end
  end


  newparam(:manage_property) do
    desc <<-EOT
    The manage property parameter defined which property to manage on the resource.
    The property defined here will be set with the value of `state` and then
    the `sync` method is called on the resources property.
    `manage_property` defaults to "ensure"
    EOT

    defaultto :ensure
  end

  newparam(:state) do
    desc <<-EOT
    Define the desired state of the purged resources.  This sets the value of the
    property defined in `manage_property` before `sync` is called on the property.
    `state` defaults to "absent"
    EOT

    defaultto :absent
  end


  [ :unless, :if ]. each do |param_name|
    newparam(param_name, :array_matching => :all) do

      desc(<<-EOT)
      Purge resources #{param_name.to_s} they meet the criteria.
      Criteria is defined as an array of "parameter", "operator", and "value".

      Eg:
         #{param_name.to_s} => [ 'name', '==', 'root' ]

      Operators can support "!=","==","=~",">","<","<=",">=" as an argument
      Value can be a string, integer or regex (without the enclosing slashes)

      Multiple criterias can be nested in an array, eg:

         #{param_name.to_s} => [
           [ 'name', '==', 'root' ], [ 'name', '=~', 'admin.*' ]
         ]
      EOT



      validate do |cond|
        raise ArgumentError, "must be an array" unless cond.is_a?(Array)
      end

      munge do |cond|
        if cond[0].is_a?(Array)
          cond
        else
          [ cond ]
        end
      end

      validate do |cond_param|
        case cond_param[0]
        when String
          cond = [ cond_param ]
        when Array
          cond = cond_param
        end

        cond.each do |param, operator, value|
          unless ["!=","==","=~",">","<","<=",">="].include?(operator)
            raise ArgumentError, "invalid operator #{operator}"
          end

          unless param && operator && value
            raise ArgumentError, "not enough parameters given for filter"
          end
        end
      end
    end
  end


  def manage_property
    self[:manage_property].to_sym
  end

  def state
    self[:state]
  end

  def generate
    klass = Puppet::Type.type(self[:name])

    unless klass.validproperty?(manage_property)
      err "Purge of resource type #{self[:name]} failed, #{manage_property} is not a valid property"
    end

    resource_instances = klass.instances
    metaparams = @parameters.select { |n, p| p.metaparam? }

    @purged_resources = []

    ## Don't try and purge things that are in the catalog
    resource_instances.reject!{ |r| catalog.resource_refs.include? r.ref }

    ## Don't purge things that have been filtered with if/unless
    resource_instances = resource_instances.select { |r| purge?(r) }

    ## Don't purge things that are already in sync
    resource_instances = resource_instances.reject { |r|
      is = begin
             r.property(manage_property).retrieve
           rescue NoMethodError
             r.retrieve[manage_property]
           end
      should = is.is_a?(Symbol) ? state.to_sym : state
      is == should
    }

    if resource_instances.length > 0
      resource_instances.each do |res|
        res.property(manage_property).should=(state)

        # Whatever metaparameters we have assigned we allocate to the
        # purged resource, this sets the same relationships on the resource
        # we are purging that we have in this resource.
        @parameters.each do |name, param|
          res[name] = param.value if param.metaparam?
        end
        Puppet.debug("Purging resource #{res.ref} with #{manage_property} => #{state}")
        @purged_resources << res
      end
    end
    @purged_resources
  end

  # This method is called from the ensure block after generate() has
  # identified resources to purge.  If it returns true then it indiciates
  # that resources have been purged and therefore puts the purge resource
  # in a changed state so it can be used in refresh event relationships
  # (notify, subscribe...etc) in Puppet.
  #
  def purged?
    purged_resources.length > 0
  end

  # purge will evaluate the conditions given in if/unless
  def purge?(res_type)

    res = res_type.to_resource.to_hash

    if self[:unless]
      return false unless evaluate_resource(res, self[:unless])
    end

    if self[:if]
      return false if evaluate_resource(res, self[:if])
    end

    return true
  end

  # evaluate_resources loops through the array of param, operator, value
  # and returns true if any of the criteria match
  #
  def evaluate_resource(res,condition)
    condition.select  {  |param, operator, value_attr|
      Array(value_attr).select { |value|
        Array(res[param.to_sym]).select { |p|
          case operator
          when "!=", "=="
            p.to_s.send(operator, value)
          when "=~"
            p =~ Regexp.new(value)
          when ">=", "<=", ">", "<"
            p.to_i.send(operator, value.to_i)
          end
        }.length > 0
      }.length > 0
    }.length == 0
  end

end

