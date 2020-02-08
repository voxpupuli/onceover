require 'yaml'
require 'json'
require 'puppet'

logs            = ARGV[-2] # Second last Arg
report          = ARGV[-1] # Last arg

result = {}

result['logs']   = JSON.load(File.read(logs)) if File.file?(logs)
result['report'] = YAML.load_file(report)     if File.file?(report)

puts result.to_json