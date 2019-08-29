# Get the facts for a server
#
# This uses `puppet facts` instead of facter but does basically the same thing as the
# facts plan
#
# @param target The server to run on
#
plan onceover::puppet_facts (
  Target $target
) {
  $node_facts = run_task('onceover::puppet_facts', $target).first.value['values']
  $target.add_facts($node_facts)
  return $node_facts
}
