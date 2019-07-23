# This should end up exactly the same in the test, backslashes should be
# preserved
$backslashes = '\2'

# Cheak that things haven't been escaped
unless $backslashes[0] == "\\" { fail() }
unless $backslashes[1] == '2' { fail() }
