# Find the correct target for a given test
#
# This accepts a test and a list of targets, it then filters through the
# targets and finds that one that is relevant to the test. It then gives
# this as a parameter to the block that is given so that it can be acted upon
#
# @param test The test that we care about
# @param targets All of the targets that we need to filter though
#
Puppet::Functions.create_function(:'onceover::on_test_target') do
  dispatch :get do
    param 'Hash', :test
    param 'Variant[TargetSpec,Array]', :targets
    block_param 'Callable', :block
  end

  def get(test, targets)
    target_name = test['node']['name']
    target      = targets.select { |t| call_function('vars',t)['name'] == target_name }.first

    yield(target)
  end
end