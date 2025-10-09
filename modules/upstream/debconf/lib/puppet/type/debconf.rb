# frozen_string_literal: true

Puppet::Type.newtype(:debconf) do
  desc <<-EOT
    @summary
      Manage debconf database entries on Debian based systems.

    This type can either set or remove a value for a debconf database
    entry. It uses multiple programs from the `debconf` package.

    @example Set a select value
      debconf { 'tzdata/Areas':
        type  => 'select',
        value => 'Europe',
      }

    @example Set a boolean value
      debconf { 'dash/sh':
        type  => 'boolean',
        value => 'true',
      }

    @example Set a boolean value in a specified package and mark as seen
      debconf { 'libraries/restart-without-asking':
        package => 'libc6',
        type    => 'boolean',
        value   => 'true',
        seen    => true,
      }
  EOT

  def self.instances
    raise _('Listing debconf instances is not supported.')
  end

  def munge_boolean(value)
    case value
    when true, 'true', :true
      :true
    when false, 'false', :false
      :false
    else
      raise(Puppet::Error, 'munge_boolean only takes booleans')
    end
  end

  ensurable do
    desc 'Specifies whether the resource should exist. Setting this to
      "absent" tells Puppet to remove the debconf entry if it exists, and
      negates the effect of any other parameters.'

    defaultvalues
    defaultto :present
  end

  newparam(:name, namevar: true) do
    desc "The name of the resource. If the parameter 'item' is not set, then
      this value will be used for it. You can set the same item in different
      packages by using different names for the resources."
  end

  newparam(:item) do
    desc "The item name. This string must have the following format: the
      package name, a literal slash char and the name of the question (e.g.
      'tzdata/Areas'). The default value is the title of the resource."

    defaultto { @resource[:name] }
    newvalues(%r{^[a-z0-9][a-z0-9:.+-]+/[a-zA-Z0-9/_.+-]+$})
  end

  newparam(:package) do
    desc "The package the item belongs to. The default is the first part (up
      to the first '/') of the item parameter (e.g. 'tzdata')."

    newvalues(%r{^[a-z0-9][a-z0-9:.+-]+$})
    defaultto { @resource[:item].split('/', 2).first }
  end

  newparam(:type) do
    desc "The type of the item. This can only be one of the following
      values: string, boolean, select, multiselect, note, text, password,
      title."

    newvalues(:string, :boolean, :select, :multiselect,
              :note, :text, :password, :title)
  end

  newproperty(:value) do
    desc "The value for the item (e.g. 'Europe')."

    munge(&:strip)              # Remove leading and trailing spaces
  end

  newproperty(:seen, boolean: true) do
    desc "The value of the 'seen' flag. This can be left undefined or be one
      of the boolean values true or false."

    newvalues(:true, :false)

    munge do |value|
      @resource.munge_boolean(value)
    end
  end

  validate do
    raise(Puppet::Error, 'type is a required attribute') unless self[:type] || self[:ensure].to_s == 'absent'
  end
end
