#! /bin/bash

csr=`cat`

csr_text=$(echo "$csr" | openssl req -noout -text)
certname=$1

# The challenge password for each node should be:
# the sha512sum of the hostname with a salt of
# "securityishard" appended to the end.

salt=`date +"%Y%m%d%H%M"`

# Calculate the expected sha512sum
# This is complex because we have to cut some trailing whitespace off
expected_sum=$(echo "$certname$salt" | sha512sum | rev | cut -c 4- | rev)

if [[ $csr_text == *"$expected_sum"* ]]
then
  exit 0
fi

exit 1
