# # CD4PE
#
# Creates a CD4PE server with all components running on the same machine, this
# includes:
#   - Artifactory: `8081`
#   - CD4PE: `8080`
#
# ## Login Details
#
# ### Root User
#
# Username: `root`
# Email: `noreply@puppet.com`
# Password: `puppetlabs`
#
# ### Personal User
#
# Username: `dylanratcliffe`
# Email: dylan.ratcliffe@puppet.com
# Password: `puppetlabs`
#
# ## Manual Configuration
#
# 1. Register for an account using the personal user credentials
# 1. NEED TO SET UP GITLAB
class role::cd4pe {
  include profile::base
  include profile::cd4pe::replicated
}
