#
class profile::sumologic {
  $sumologic_key = hiera('profile::sumologic::sumologic_key','NOT_FOUND')

  # This data is completely made up, it will not work
  class { '::sumologic::report_handler':
    report_url => "https://collectors.au.sumologic.com/receiver/v1/http/${sumologic_key}",
    mode       => 'json',
    notify     => Service['pe-puppetserver'],
  }
}
