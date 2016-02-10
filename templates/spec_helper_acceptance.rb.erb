# This has all been hacked out of the beaker-rspec gem. The reason I have
# hacked it out instead of just using it the way it was intended is that
# it is very stuck in its ways around how it spins up all the servers
# first, then goes ahead and runs the tests. Because I don't want to do this
# I have had to replicate MOST of the functionality, EXCEPT the stuff I don't
# want. This is annoying but as far as I can tell this is the only way to do
# it

require 'beaker'
require 'beaker-rspec/beaker_shim' # This overloads Rspec's methods and provides the interface between beaker and RSpec
require "beaker-rspec/helpers/serverspec"
include BeakerRSpec::BeakerShim
require 'controlrepo/beaker'

#scp_to hosts, '<%= repo.tempdir %>/etc', '/'

RSpec.configure do |c|
  # Enable color
  c.color = true
  c.tty = true

  # Readable test descriptions
  c.formatter = :documentation

  # Define persistant hosts setting
  c.add_setting :hosts, :default => []
  # Define persistant options setting
  c.add_setting :options, :default => {}
  # Define persistant metadata object
  c.add_setting :metadata, :default => {}
  # Define persistant logger object
  c.add_setting :logger, :default => nil
  # Define persistant default node
  c.add_setting :default_node, :default => nil

  #default option values
  defaults = {
    :nodeset     => 'controlrepo-nodes',
  }
  #read env vars
  env_vars = {
    :color       => ENV['BEAKER_color'] || ENV['RS_COLOR'],
    :nodeset     => ENV['BEAKER_set'] || ENV['RS_SET'],
    :nodesetfile => ENV['BEAKER_setfile'] || ENV['RS_SETFILE'],
    :provision   => ENV['BEAKER_provision'] || ENV['RS_PROVISION'],
    :keyfile     => ENV['BEAKER_keyfile'] || ENV['RS_KEYFILE'],
    :debug       => ENV['BEAKER_debug'] || ENV['RS_DEBUG'],
    :destroy     => ENV['BEAKER_destroy'] || ENV['RS_DESTROY'],
  }.delete_if {|key, value| value.nil?}
  #combine defaults and env_vars to determine overall options
  options = defaults.merge(env_vars)

  # process options to construct beaker command string
  nodesetfile = options[:nodesetfile] || File.join('spec/acceptance/nodesets',"#{options[:nodeset]}.yml")
  fresh_nodes = options[:provision] == 'no' ? '--no-provision' : nil
  keyfile = options[:keyfile] ? ['--keyfile', options[:keyfile]] : nil
  debug = options[:debug] ? ['--log-level', 'debug'] : nil
  color = options[:color] == 'no' ? ['--no-color'] : nil

  # Configure all nodes in nodeset
  c.setup([fresh_nodes, '--hosts', nodesetfile, keyfile, debug, color].flatten.compact)
  #c.provision
  #c.validate
  #c.configure
end

# Set the number of lines it will print
options[:trace_limit] = 1000

OPTIONS = options
