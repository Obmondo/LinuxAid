# _Description_
#
# Set a fact with all of the sample ruleset names if they exist on
# the system for being able to utilize included rulesets
#
# Current output is hash containing:
# {
#   <policy_name>:
#     order: <policy_order>
# }
#
Facter.add('auditd_sample_rulesets') do
  confine kernel: 'Linux'

  confine do
    !Facter.value(:auditd_sample_ruleset_location).nil?
  end

  setcode do
    retval = {}

    Dir["#{Facter.value(:auditd_sample_ruleset_location)}/*.rules"].map do |x|
      order, name = File.basename(x, '.rules').split('-', 2)
      retval[name] = { 'order' => order }
    end

    retval
  end
end
