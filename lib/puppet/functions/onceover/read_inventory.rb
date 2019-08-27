# Currently not used
Puppet::Functions.create_function(:'onceover::read_inventory') do
  dispatch :read do
    param 'String', :inventory_file
  end

  def read(inventory_file)
    require 'bolt'
    require 'yaml'

    Bolt::Inventory.new(YAML.safe_load(File.read(inventory_file)))
  end
end