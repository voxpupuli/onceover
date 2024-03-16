# # Generic MySQL Server
# 
# Installs a generic MySQL server accoring to the forge module
#
# **OS:** RedHat
#
# ## Listening Services
#
# * MySQL: `3306`
class role::mysql {
  include ::profile::base
  include ::profile::mysql_server
}
