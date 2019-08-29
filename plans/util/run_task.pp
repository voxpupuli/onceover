# Runs a Onceover::Task on a machine
#
# This is basically just a thin shim that unpacks and abstracts the
# Onceover::Task object so people don't have to worry about what's in
# there and I can change it later.
#
# @param target The node/s to run on
# @param task The task to run
plan onceover::util::run_task (
  TargetSpec     $target,
  Onceover::Task $task,
) {
  return run_task(
    $task['name'],
    $target,
    $task['parameters']
  )
}
