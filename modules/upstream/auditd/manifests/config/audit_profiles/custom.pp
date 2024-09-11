# @summary A set of user specified rules in a form that is easy to manipulate via Hiera
#
# **NO SANITY CHECKING IS PERFORMED ON THE RESULTING RULES**
#
# @example Passing an Array of Rules
#
#  ---
#  auditd::config::audit_profiles::custom::rules:
#    - "-a always,exit -F arch=b64 -S creat -F exit=-EACCES -k unsuccessful_file_operations"
#    - "-w /etc/passwd -p wa -k passwd_changes"
#
# @example Passing an EPP Template
#
#  ---
#  auditd::config::audit_profiles::custom::template: "my_templates_module/auditd/my_audit_rules.epp"
#
# @example Passing an ERB Template
#
#  ---
#  auditd::config::audit_profiles::custom::template: "my_templates_module/auditd/my_audit_rules.erb"
#
# @param rules
#   An Array of rules that will be joined with a ``\n`` and inserted as the
#   **complete** audit rule set to be applied to the system.
#
#
# @param template
#   A template specification as you would pass to either the `epp` or `erb`
#   function
#
#   * Specifying both `rules` and `template` will result in an error
#
# @author https://github.com/simp/pupmod-simp-auditd/graphs/contributors
#
class auditd::config::audit_profiles::custom (
  Optional[Array[String[1]]] $rules    = undef,
  Optional[String[1]]        $template = undef
) {
  assert_private()

  if ($rules and $template) {
    fail('You may not specify both "$rules" and "$template"')
  }

  unless ($rules or $template) {
    fail('You must specify either "$rules" or "$template"')
  }

  if $rules {
    $_custom_rules = join($rules, "\n")
  }

  if $template {
    if $template =~ /\.epp$/ {
      $_custom_rules = epp($template)
    }
    elsif $template =~ /\.erb$/ {
      $_custom_rules = template($template)
    }
    else {
      fail('Your template must end with either ".epp" or ".erb"')
    }
  }

  $_short_name = 'custom'
  $_idx = auditd::get_array_index($_short_name, $auditd::config::profiles)

  file { "/etc/audit/rules.d/50_${_idx}_${_short_name}_base.rules":
    content => "${_custom_rules}\n"
  }
}
