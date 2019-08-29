# Converts data from the format that is in the inventory.yaml
# to a format that `Target.new()` is expecting
#
# @param node The node details as per inventory.yaml
#
function onceover::node_to_target (
  Hash $node,
) {
  {
    'uri'     => "${node['config']['transport']}://${node['name']}",
    'options' => $node['config'][$node['config']['transport']],
  }
}
