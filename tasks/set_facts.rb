#!/opt/puppetlabs/puppet/bin/ruby

require 'json'
require 'puppet'

params = JSON.parse(STDIN.read)
facts  = params['facts']

begin
  Puppet.initialize_settings
  factsdir = Puppet[:pluginfactdest]
  facts.each do |name, value|
    contents = { name => value }
    File.write("#{factsdir}/#{name}.json", contents.to_json)
  end
  puts facts.to_json
  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end