require 'puppet/property'

begin
  require 'puppet_x/util/boolean'
rescue LoadError
  libdir = Pathname.new(__FILE__).parent.parent.parent
  require File.join(libdir, 'puppet_x/util/boolean')
end

class Puppet::Property::Boolean < Puppet::Property
  include PuppetX::Util::Boolean

  # Determine if the boolean property is in sync.
  def insync?(is)
    munge(is) == should
  end
end
