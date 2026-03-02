
# @summary Class for managing the Rsyslog server role
#
# @param global_config Global configuration for Rsyslog. Defaults to an empty hash.
#
# @param legacy_config Legacy configuration for Rsyslog. Defaults to an empty hash.
#
# @param templates Configuration templates for Rsyslog. Defaults to an empty hash.
#
# @param actions Actions for Rsyslog. Defaults to an empty hash.
#
# @param inputs Inputs for Rsyslog. Defaults to an empty hash.
#
# @param custom_config Custom configuration for Rsyslog. Defaults to an empty hash.
#
# @param main_queue_opts Main queue options for Rsyslog. Defaults to an empty hash.
#
# @param modules Modules for Rsyslog. Defaults to an empty hash.
#
# @param lookup_tables Lookup tables for Rsyslog. Defaults to an empty hash.
#
# @param parsers Parsers for Rsyslog. Defaults to an empty hash.
#
# @param rulesets Rulesets for Rsyslog. Defaults to an empty hash.
#
# @param property_filters Filters for properties in Rsyslog. Defaults to an empty hash.
#
# @param expression_filters Filters for expressions in Rsyslog. Defaults to an empty hash.
#
# @param $__blendable 
# Boolean indicating if the configuration is blendable. No default.
#
# @groups configs global_config, legacy_config, custom_config.
#
# @groups filters property_filters, expression_filters.
#
# @groups structures templates, actions, inputs, modules, lookup_tables, parsers, rulesets.
#
# @groups options main_queue_opts.
#
class role::monitoring::rsyslog (
  Optional[Hash] $global_config      = {},
  Optional[Hash] $legacy_config      = {},
  Optional[Hash] $templates          = {},
  Optional[Hash] $actions            = {},
  Optional[Hash] $inputs             = {},
  Optional[Hash] $custom_config      = {},
  Optional[Hash] $main_queue_opts    = {},
  Optional[Hash] $modules            = {},
  Optional[Hash] $lookup_tables      = {},
  Optional[Hash] $parsers            = {},
  Optional[Hash] $rulesets           = {},
  Hash           $property_filters    = {},
  Hash           $expression_filters  = {},
  Boolean        $__blendable,
) {

  class { 'profile::rsyslog':
    global_config      => $global_config,
    legacy_config      => $legacy_config,
    templates          => $templates,
    actions            => $actions,
    inputs             => $inputs,
    custom_config      => $custom_config,
    main_queue_opts    => $main_queue_opts,
    modules            => $modules,
    lookup_tables      => $lookup_tables,
    parsers            => $parsers,
    rulesets           => $rulesets,
    property_filters   => $property_filters,
    expression_filters => $expression_filters,
  }
}
