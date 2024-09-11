# == Define: curator::action
#
# Defines a specific action
#
# === Parameters
#
# [*name*]
#   String.  Valid values: Alias, Allocation, Close, Create Index, Delete Indices, Delete Snapshots,
#            Open, forceMerge, Replicas, Restore, Shrink, Snapshot
#   Default:
#
# [*description*]
#   String.  Description for the action
#   Default: ''
#
# [*allocation_type*]
#   String.  Read more about these settings at http://www.elastic.co/guide/en/elasticsearch/reference/current/shard-allocation-filtering.html
#   Default: undef
#
# [*continue_if_exception*]
#   Boolean. If continue_if_exception is set to True, Curator will attempt to continue on to the next action,
#            if anymore, even if an exception is encountered. Curator will log but ignore the exception that was raised.
#   Default: 'False'
#
# [*count*]
#   Number.  The value for this setting is the number of replicas to assign to matching indices.
#   Default: undef
#
# [*delay*]
#   Number.  The value for this setting is the number of seconds to delay between forceMerging indices, to allow the cluster to quiesce.
#   Default: undef
#
# [*delete_aliases*]
#   Number.  The value for this setting determines whether aliases will be deleted from indices before closing.
#   Default: undef
#
# [*disable_action*]
#   Boolean. If disable_action is set to True, Curator will ignore the current action.
#            This may be useful for temporarily disabling actions in a large configuration file.
#   Default: False
#
# [*ignore_empty_list*]
#   Boolean. Depending on your indices, and how you’ve filtered them, an empty list may be presented to the action.
#            This results in an error condition.
#   Default: False
#
# [*shrink_node*]
#   String.  Read more about these setting at https://www.elastic.co/guide/en/elasticsearch/client/curator/current/option_shrink_node.html
#   Default: undef
#
# [*copy_aliases*]
#   Boolean. If copy_aliases is set to True, Curator will copy the source index to the target index after the successful action.
#   Default: undef
#
# [*delete_after*]
#   Boolean. Curator will delete the source index after the successful action.
#   Default: undef
#
# [*node_filters*]
#   Array. Read more about there setting at https://www.elastic.co/guide/en/elasticsearch/client/curator/current/option_node_filters.html
#   Default: undef
#
# [*number_of_shards*]
#   Number.  The value for this setting determines determines the number of primary shards in the target index.
#   Default: undef
#
# [*number_of_replicas*]
#   Number.  The value for this setting determines determines the number of replica shards per primary shard in the target index.
#   Default: undef
#
# [*post_allocation*]
#   Array.  These values will be use to apply shard routing allocation to the target index after shrinking.
#   Default: undef
#
# [*shrink_prefix*]
#   String.  This value will be prepended to target index names.
#   Default: undef
#
# [*shrink_suffix*]
#   String.  This value will be appended to target index names.
#   Default: undef
#
# [*wait_for_active_shards*]
#   String.  This value determines the number of shard copies that must be active before the client returns.
#   Default: undef
#
# [*wait_for_rebalance*]
#   Boolean.  Curator will action for index being shrunk and not wait for the cluster to fully rebalance all shards.
#   Default: undef
#
#  ___TBC___
#
# [*filters*]
#   Array.   Array of hashes
#   Default: []
define curator::action (
  $action                 = $name,
  $description            = $name,
  $allocation_type        = undef,
  $continue_if_exception  = 'False',
  $copy_aliases           = undef,
  $count                  = undef,
  $delay                  = undef,
  $delete_after           = undef,
  $delete_aliases         = undef,
  $disable_action         = 'False',
  # $extra_settings = undef, #We don't support $extra_settings yet
  $ignore_empty_list      = 'False',
  $ignore_unavailable     = undef,
  $include_aliases        = undef,
  $include_global_state   = undef,
  $indices                = undef,
  $key                    = undef,
  $max_num_segments       = undef,
  $number_of_replicas     = undef,
  $number_of_shards       = undef,
  $node_filters           = undef,
  $option_name            = undef,
  $partial                = undef,
  $post_allocation        = undef,
  $rename_pattern         = undef,
  $rename_replacement     = undef,
  $repository             = undef,
  $retry_count            = undef,
  $retry_interval         = undef,
  $shrink_node            = undef,
  $shrink_prefix          = undef,
  $shrink_suffix          = undef,
  $skip_repo_fs_check     = undef,
  $timeout_override       = undef,
  $value                  = undef,
  $wait_for_active_shards = undef,
  $wait_for_completion    = undef,
  $wait_for_rebalance     = undef,
  $filters                = [],
  $order                  = 1,
){
  include ::curator

  if !member([
    'alias',
    'allocation',
    'close',
    'create_index',
    'delete_indices',
    'delete_snapshots',
    'open',
    'forcemerge',
    'replicas',
    'restore',
    'shrink',
    'snapshot',
    ], $action) {
    fail("Incorrect action name: ${$action}, Check https://www.elastic.co/guide/en/elasticsearch/client/curator/current/actions.html")
  }

  if ($allocation_type and !member(['allocation', 'shrink',], $action)) {
    fail("${allocation_type} can only be set for action = allocation or shrink")
  }
  if ( $allocation_type and !member(['require', 'include', 'exclude',], $allocation_type)) {
    fail("${allocation_type} must be require, include or exclude")
  }

  if $count and $action != 'replicas' {
    fail('$count can be set only for action = replicas')
  }

  if ($delay or $max_num_segments) and $action != 'forcemerge' {
    fail('$delay can be set only for action = forcemerge')
  }

  if $delete_aliases and $action != 'close' {
    fail('$delete_aliases can be set only for action = close')
  }

  if ($include_aliases or $indices or $rename_pattern or $rename_replacement) and $action != 'restore' {
    fail('$include_aliases can be set only for action = restore')
  }

  if ($include_global_state or $ignore_unavailable or $partial or $skip_repo_fs_check) and $action != 'snapshot' {
    fail('$include_global_state can be set only for action = snapshot')
  }

  if ($key or $value) and !member(['allocation', 'shrink',], $action) {
    fail('$key can be set only for action = allocation or shrink')
  }

  if $repository and !member(['delete_snapshots', 'snapshot',], $action) {
    fail('$repository can be set only for action = delete_snapshots or snapshot')
  }

  if ($retry_count or $retry_interval) and $action != 'delete_snapshots' {
    fail('$retry_count can be set only for action = delete_snapshots')
  }

  if $wait_for_completion and !member(['allocation', 'replicas', 'restore', 'snapshot', 'shrink'], $action) {
    fail('$wait_for_completion can be set only for action = allocation or replicas or restore or snapshot or shrink')
  }

  if ($copy_aliases or $delete_after or $shrink_node or $node_filters or
  $number_of_shards or $number_of_replicas or $post_allocation or $shrink_prefix or
  $shrink_suffix or $wait_for_active_shards or $wait_for_rebalance) and $action != 'shrink' {
    fail('This action can be set only for action = shrink')
  }

  concat::fragment { "${name}_action":
    target  => $curator::actions_file,
    content => template("${module_name}/action.erb"),
    order   => "${order}_${name}",
  }
}
