# This class patches the Puppet MoMs to allow all nodes that are able to access
# the file-sync API to also be clients
class profile::file_sync::master_patch {
  # This repliaces the logic from the puppet_enterprise::master::file_sync
  # class in order add our file_sync server to the list of allowed clients. 
  # Note that the server muct be specified using hiera with the 
  # puppet_enterprise::master::file_sync::whitelisted_certnames key
  $masters_in_puppetdb = map(
    puppetdb_query(['from', 'resources',
                    ['extract', ['certname'],
                      ['and', ['=', 'type', 'Class'],
                      ['=', 'title', 'Puppet_enterprise::Profile::Master'],
                      ['=', ['node','active'], true]]]])) |$master| { $master['certname'] }
  $file_sync_clients_in_puppetdb = map(
    puppetdb_query(['from', 'resources',
                    ['extract', ['certname'],
                      ['and', ['=', 'type', 'Class'],
                      ['=', 'title', 'Profile::File_sync::Client'],
                      ['=', ['node','active'], true]]]])) |$master| { $master['certname'] }
  $whitelisted_certnames = lookup('puppet_enterprise::master::file_sync::whitelisted_certnames', {'default_value' => []})
  $list                  = $whitelisted_certnames + $file_sync_clients_in_puppetdb + $masters_in_puppetdb
  $authorized_certs      = pe_union([$facts['certname']], $list)
  $certs_authorized_to_communicate_with_file_sync = pe_sort(delete_undef_values(pe_unique($authorized_certs)))


  Pe_hocon_setting <| title == 'file-sync.client-certnames' |> {
    value => $certs_authorized_to_communicate_with_file_sync,
  }

  Pe_puppet_authorization::Rule <| title == 'puppetlabs file sync api' |> {
    allow => $certs_authorized_to_communicate_with_file_sync,
  }

  Pe_puppet_authorization::Rule <| title == 'puppetlabs file sync repo' |> {
    allow => $certs_authorized_to_communicate_with_file_sync,
  }
}
