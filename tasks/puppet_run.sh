#!/bin/sh
MANIFEST=$(puppet config print manifest)
ENVIRONMENTPATH=$(puppet config print environmentpath)

# Create a temp file to apply
APPLY_MANIFEST=$(mktemp)
LOG=$(mktemp)
LOG="${LOG}.json"
PRE_CONDITTIONS_PATH="${ENVIRONMENTPATH}/production/spec/pre_conditions"

# Include the manifest and all pre_conditions
cat ${MANIFEST}/*.pp             2>/dev/null >> $APPLY_MANIFEST
cat ${PRE_CONDITTIONS_PATH}/*.pp 2>/dev/null >> $APPLY_MANIFEST
echo "include ${PT_role}"        2>/dev/null >> $APPLY_MANIFEST

# Run Puppet
/opt/puppetlabs/bin/puppet apply $APPLY_MANIFEST --logdest $LOG >/dev/null 2>&1

# Close off the logs
echo "]" > $LOG

REPORT=$(/opt/puppetlabs/bin/puppet config print lastrunreport)

if test -f "$REPORT"; then
  /opt/puppetlabs/puppet/bin/ruby "../../onceover/files/run_details.rb" $LOG $REPORT
else
  echo $OUTPUT
  exit 1
fi
