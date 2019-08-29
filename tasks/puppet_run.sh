#!/bin/sh

/opt/puppetlabs/bin/puppet apply -e "include $PT_role"  > /dev/null 2>&1

REPORT=$(/opt/puppetlabs/bin/puppet config print lastrunreport)

/opt/puppetlabs/puppet/bin/ruby -rjson -ryaml -rpuppet -e "puts YAML.load_file('$REPORT').to_json"
