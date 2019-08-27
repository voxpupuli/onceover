# Returns the major verison of Puppet
Puppet::Functions.create_function(:'onceover::puppet_version') do
  dispatch :version do
    # No parameters
  end

  def version()
    Puppet.version
  end
end