#
class role::windows::webserver {
  include ::profile::base::windows
  include ::profile::windows::webserver
  include ::profile::sunburst::windows
}
