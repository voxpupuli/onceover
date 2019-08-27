# Run Post-Build Tasks
#
# Runs all of the post-build tasks on a node. These should be stored in the
# node itself so the only thing we need is the node.
#
# @param node The node to run on
plan onceover::acceptance::post_install (
  TargetSpec $node,
) {
  if $node.vars['post-install-tasks'] {
    # Execute each task in turn
    $node.vars['post-install-tasks'].each |$task| {
      run_plan('onceover::util::run_task', {
        'target' => $node,
        'task'   => $task,
      })
    }
  }
}
