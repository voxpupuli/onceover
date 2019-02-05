Puppet::Functions.create_function(:'profile::fail_ruby') do
  dispatch :fail do
    param 'String', :message
  end

  def fail(message)
    call_function('fail', message)
  end
end