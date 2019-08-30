# Reloads an inventory
#
# This is basically the worst thing I've ever written, there is so much wrong
# with this. However there is also no other way to reload an inventory file
# while in-flight.
#
# Don't email me if this breaks.
#
Puppet::Functions.create_function(:'onceover::reload_inventory') do
  dispatch :reload do
    optional_param 'String', :inventory_path
  end

  def reload(inventory_path)
    require 'bolt/inventory'

    # Find the current inventroy object
    old_inventory  = Puppet.lookup(:bolt_inventory)

    # Work out where that file is on disk using horrible hacks
    config         = old_inventory.instance_variable_get(:@config)
    inventory_file = config.inventoryfile || "#{inventory_path}/inventory.yaml"

    # Re-initialise a new object
    new_inventory  = Bolt::Inventory.new(YAML.safe_load(File.read(inventory_file)))

    instance_vars_exclude = [
      :@target_vars,
      :@target_facts,
      :@target_features,
    ]

    # Go through and replace all of the instance variables because this seems
    # to be the only way to get this to work
    old_inventory.instance_variables.each do |var|
      # Replace instance variables unless thay need to be kept
      unless instance_vars_exclude.include? var
        old_inventory.instance_variable_set(var, new_inventory.instance_variable_get(var))
      end
    end
  end
end