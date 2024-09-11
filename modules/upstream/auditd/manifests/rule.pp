# @summary Add rules to the audit daemon.
#
# All rules must be uniquely named.  See ``auditctl(8)`` for more information
# on how to write the content for these rules.
#
# @param name
#   A unique identifier for the audit rules.
#
# @param content
#   The content of the rules that should be added.
#
#   * Arrays will be joined with a newline
#
# @param order
#   An alphanumeric (file system ordering) order string
#
#  * Overrides all other ordering parameters
#
# @param first
#   Set this to 'true' if you want to prepend your custom rules (numeric 10)
#
# @param absolute
#   Set this to ``true`` if you want the added rules to be absolutely first or
#   last depending on the setting of ``$first``.
#
# @param prepend
#   Prepend this rule to all other rules (numeric 00).
#
# @author https://github.com/simp/pupmod-simp-auditd/graphs/contributors
#
define auditd::rule (
  Variant[Array[String[1]],String[1]] $content,
  Optional[String[1]]                 $order    = undef,
  Boolean                             $first    = false,
  Boolean                             $absolute = false,
  Boolean                             $prepend  = false
) {
  include 'auditd'

  if $auditd::enable {

    $_safe_name = regsubst($name, '(/|\s)', '__')

    if $order {
      $_order = $order
    }
    elsif $prepend {
      $_order = '00'
    }
    else {
      if $first {
        if $absolute {
          $_order = '01'
        }
        else {
          $_order = '10'
        }
      }
      else {
        $_order = '75'
      }
    }

    $_rule_id = "${_order}.${_safe_name}.rules"

    file { "/etc/audit/rules.d/${_rule_id}":
      content => epp("${module_name}/rule.epp", { content => $content }),
      notify  => Class['auditd::service']
    }
  }
  else {
    debug("Auditd is disabled, not activating auditd::rule::${name}")
  }
}
