# Fact: rhn_subscription
#
# Purpose: determine if the node has a working RHN subscription
#
# Resolution:
#   Checks the output of `subscription-manager list` and returns `true` if a
#   valid subscription exists. Returns `nil` if unable to get subscription
#   status.
#
# Caveats:
#   none
#
# Notes:
#   None
#
# Author: Rune Juhl Jacobsen <runejuhl@enableit.dk>

Facter.add(:rhn_subscription) do
  confine :kernel => 'Linux'
  confine :os do |os|
    os['name'] == 'RedHat'
  end

  setcode do
    lambda {
      full_output = `subscription-manager list`
      unless $?.exitstatus.zero?
        Facter.warn 'Could not run subscription-manager'
        return false
      end

      # More than one subscription may be listed so we need to find the right
      # one.
      rhel_status = full_output.split("\n\n").grep(/^Product Name: + Red Hat Enterprise Linux Server/).first
      if rhel_status.nil?
        Facter.warn 'Could not find RHEL subscription'
        return false
      end

      status = rhel_status.split("\n").grep(/^Status:.+/).first
      if status.nil?
        Facter.warn 'Could not find RHEL subscription status'
        return false
      end

      status = status.split[1]

      Facter.debug 'Subscription status is "#{status}"'
      return status == 'Subscribed'
    }.call
  end
end
