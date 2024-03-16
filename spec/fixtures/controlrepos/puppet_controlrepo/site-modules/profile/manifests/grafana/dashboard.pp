define profile::grafana::dashboard (
  $metrics_server_id,
) {
  # Swap dots for underscores as grafana deasn't like dots
  $safe_title = regsubst($title,'\.','_','G')

  file { "/opt/grafana/app/dashboards/${safe_title}.json":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0664',
    content => epp('profile/dashboard.json.epp',{
      'title'             => $title,
      'metrics_server_id' => $metrics_server_id,
      }),
  }
}
