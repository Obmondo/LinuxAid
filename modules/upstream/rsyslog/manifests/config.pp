# @summary
#   Manage the configuration parameters for rsyslog.
#   This class can be called explicitly or through the use of
#   hieradata.
#
# @author Vox Pupuli <voxpupuli@groups.io>
#
# @example using class
#   class { 'rsyslog::config':
#     global_config      => {
#       'workDirectory'  => {
#         'value'        => '/var/spool/rsyslog',
#       },
#       'maxMessageSize' => {
#         'value'        => '64k'
#       }
#     },
#     actions            => {
#       'all_logs'       => {
#         'type'         => 'omfile',
#         'facility'     => '*.*;auth,authpriv.none',
#         'config'       => {
#           'dynaFile'   => 'remoteSyslog',
#           'specifics'  => '/var/log/test',
#         },
#       },
#     },
#   }
#
# @example using hieradata
#   # Include class
#   include rsyslog::config
#
#   # Hieradata
#   ---
#   rsyslog::config::global_config:
#     workDirectory:
#       value: '/var/spool/rsyslog'
#     maxMessageSize:
#       value: '64k'
#   rsyslog::config::actions:
#     all_logs:
#       type: omfile
#       factiliy: "*.*;auth,authpriv.none"
#       config:
#         dynaFile: remoteSyslog
#         specifics: '/var/log/test'
#
# @param global_config
#   Hash of global configuration options. Supports both Rainerscript and Legacy
#   configuration formats depending on the configuration option.
#   * :name (String) [undef] Name of the global configuration option to set.
#     * :priority (Integer) [10] Sets where in the config the option will be placed in the target file.
#     * :target (String) [50_rsyslog.conf] File to place the conf
#     * :confdir (String) [/etc/rsyslog.d] Directory where the configuration file exists.
#     * :value (String) [] Value of the configuration item
#     * :config (Hash) [{}] Hash of configuration data for the option. Contents
#     dependent on the configuration option.
#     * :type (Enum['rainerscript', 'legacy']) [rainerscript] configuration format to use.
#     * :format (String) ['<%= $content %>'] The content format. Defaults to epp template code.
# @param legacy_config
#   Hash of rsyslog configuration in the legacy format.
#   * :name (String) [undef] Name of the legacy configuration option.
#     * :priority (Integer) [10] Sets where in the config the option will be placed in the target file.
#     * :target (String) [50_rsyslog.conf] File to place the conf
#     * :value (String) [] Value of the configuration item
#     * :confdir (String) [/etc/rsyslog.d] The configuration directory where config file exists.
#     * :key (String) [legacy_key] The rsyslog legacy configuration key name
#     * :type (String) [sysklogd] The type of legacy configuration it is.
#     * :format (String) ['<%= $content %>'] The content format. Defaults to epp template code.
# @param templates
#   Hash of rsyslog templates.
#   * :name (String) [undef] Name of the global configuration option to set.
#     * :priority (Integer) [10] Sets where in the config the option will be placed in the target file.
#     * :target (String) [50_rsyslog.conf] File to place the conf
#     * :confdir (String) [/etc/rsyslog.d] Directory where the configuration file exists.
#     * :type (Enum['string', 'list', 'subtree', 'plugin']) [undef] Rsyslog template type.
#     * :list_descriptions (Array) [[]] An array of hashes representing list
#     template constants and properties
#     * :string (String) [''] String value for a String template.
#     * :subtree (String) [''] String representation of the subtree value.
#     * :plugin (String) [''] Name of the plugin the template will use.
#     * :options (Hash) [{}] Hash of additional template options.
#     * :format (String) ['<%= $content %>'] The content format. Defaults to epp template code.
# @param actions
#   Hash of rsyslog actions.
#   * :name (String) [undef] Name of the global configuration option to set.
#     * :priority (Integer) [10] Sets where in the config the option will be placed in the target file.
#     * :target (String) [50_rsyslog.conf] File to place the conf
#     * :confdir (String) [/etc/rsyslog.d] Directory where the configuration file exists.
#     * :type (String) [undef] Type of output module the action will use.
#     * :config (Optional[Hash]) [undef] A hash of output module specific configuration options.
#     * :facility (String) ['default'] The syslog facility to use when outputting this action.
#     * :format (String) ['<%= $content %>'] The content format. Defaults to epp template code.
# @param inputs
#   Hash of rsyslog input plugins to use.
#   * :name (String) [undef] Name of the global configuration option to set.
#     * :priority (Integer) [10] Sets where in the config the option will be placed in the target file.
#     * :target (String) [50_rsyslog.conf] File to place the conf
#     * :confdir (String) [/etc/rsyslog.d] Directory where the configuration file exists.
#     * :type (String) [undef] The name of the input module to use.
#     * :config (Optional[Hash]) [undef] Hash of input module specific
#     configuration settings. Depends on value of type
#     * :format (String) ['<%= $content %>'] The content format. Defaults to epp template code.
# @param custom_config
#   Hash of custom raw configuration to place in the rsyslog config file.
#   * :name (String) [undef] Name of the global configuration option to set.
#     * :priority (Integer) [10] Sets where in the config the option will be placed in the target file.
#     * :target (String) [50_rsyslog.conf] File to place the conf
#     * :confdir (String) [/etc/rsyslog.d] Directory where the configuration file exists.
#     * :content (String) [undef] The single/multi-line string representing the config.
#
class rsyslog::config (
  Hash $global_config = {},
  Hash $legacy_config = {},
  Hash $templates = {},
  Hash $actions = {},
  Hash $inputs = {},
  Hash $custom_config = {},
  Hash $main_queue_opts = {},
  Hash $modules = {},
  Hash $lookup_tables = {},
  Hash $parsers = {},
  Hash $rulesets = {},
  Hash $property_filters = {},
  Hash $expression_filters = {},
) {
  include rsyslog

  include rsyslog::config::modules
  include rsyslog::config::global
  include rsyslog::config::legacy
  include rsyslog::config::main_queue
  include rsyslog::config::templates
  include rsyslog::config::actions
  include rsyslog::config::inputs
  include rsyslog::config::custom
  include rsyslog::config::lookup_tables
  include rsyslog::config::parsers
  include rsyslog::config::rulesets
  include rsyslog::config::property_filters
  include rsyslog::config::expression_filters
}
