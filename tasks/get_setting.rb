#!/opt/puppetlabs/puppet/bin/ruby

require 'json'
require 'puppet'

params  = JSON.parse(STDIN.read)
setting = params['setting']

begin
  Puppet.initialize_settings
  result = { 'value' => Puppet[setting] }
  puts result.to_json
  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end