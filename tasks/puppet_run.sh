#!/bin/sh

OUTPUT=$(/opt/puppetlabs/bin/puppet apply -e "include $PT_role" 2>&1)

REPORT=$(/opt/puppetlabs/bin/puppet config print lastrunreport)

if test -f "$REPORT"; then
  /opt/puppetlabs/puppet/bin/ruby -rjson -ryaml -rpuppet -e "puts YAML.load_file('$REPORT').to_json"
else
  echo $OUTPUT
  exit 1
fi
