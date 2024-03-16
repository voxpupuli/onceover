# # Sunburst Webserver
#
# Runs a basic webserver that serves a clock on port 8080
#
# **OS:** RedHat
#
# ## Services
#
# ### Clock
#
# Protocol: HTTP
# Port: `8080`
class role::clock {
  include ::profile::base
  include ::profile::polar_clock
}
