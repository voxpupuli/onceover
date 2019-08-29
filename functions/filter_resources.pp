# Filters resoucres
#
# This function takes a hash of criteria and applies it to resources from a
# report. e.g.
#
# $report['resource_statuses'].onceover::filter_resources({
#   'changed' => true
# })
#
function onceover::filter_resources (
  Hash $resource_statuses,
  Hash $filter,
) {
  # Filter all of the resources
  $filtered = $resource_statuses.values.map |$resource_status| {
    $matches_filter = $filter.keys.onceover::all |$key| {
      $resource_status[$key] == $filter[$key]
    }

    if $matches_filter {
      $resource_status
    } else {
      undef
    }
  }

  # Remove all of the undefs
  return ($filtered - undef)
}
