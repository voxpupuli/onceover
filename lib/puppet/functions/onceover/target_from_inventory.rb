# Currently not used
Puppet::Functions.create_function(:'onceover::target_from_inventory') do
  dispatch :find do
    param 'String', :inventory_file
    param 'String', :target_name
  end

  def find(inventory_file, target_name)
    # Read in the inventory as a native bolt object
    inventory = call_function('onceover::read_inventory', inventory_file)

    # Find the Target using get_targets
    inventory.get_targets(target_name).first
  end
end