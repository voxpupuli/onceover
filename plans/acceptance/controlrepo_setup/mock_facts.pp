# Mocks facts that don't exist
#
# After we have copied over all modules etc we need to ensure that the facts
# are going to work as intended. Becuase we might be runnin in a different
# environment there's a good chance that some of the facts that we were
# relying on won't work so we need to check what these are and mock them.
#
# @param facts The facts that we expect for the machine
# @param target The machine to mock on
#
plan onceover::acceptance::controlrepo_setup::mock_facts (
  Hash   $factset,
  Target $target,
) {
  $desired_facts = $factset['values']
  $current_facts = run_task('onceover::puppet_facts', $target).first.value['values']
}
