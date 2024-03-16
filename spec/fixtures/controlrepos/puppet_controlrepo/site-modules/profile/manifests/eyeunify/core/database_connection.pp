# == Class: profile::eyeunify::core::database_connection
#
class profile::eyeunify::core::database_connection (
    Optional[String] $database_server       = undef,
    String           $database_server_query = 'facts.role = "role::eyeunify::database"',
    String           $database_name         = 'eyeunify',
    String           $username              = 'eyeunify',
    String           $password              = 'hunter2',
) {
  # Work out what the database server should be
  if $database_server {
    $_database_server = $database_server
  } else {
    $_database_server = puppetdb_query("inventory[certname] { ${database_server_query} }")[0].dig('certname')
  }

  wildfly::config::module { 'org.postgresql':
    source       => 'http://central.maven.org/maven2/org/postgresql/postgresql/9.4-1206-jdbc42/postgresql-9.4-1206-jdbc42.jar',
    dependencies => ['javax.api', 'javax.transaction.api'],
    require      => Class['::wildfly::install'],
  }

  wildfly::datasources::driver { 'Driver postgresql':
    driver_name                     => 'postgresql',
    driver_module_name              => 'org.postgresql',
    driver_xa_datasource_class_name => 'org.postgresql.xa.PGXADataSource',
    require                         => Wildfly::Config::Module['org.postgresql'],
  }

  wildfly::datasources::datasource { 'eyeUNIFY_datasource':
    name    => 'eyeUNIFY_datasource',
    config  => {
      'driver-name'           => 'postgresql',
      'connection-url'        => "jdbc:postgresql://${_database_server}/${database_name}",
      'jndi-name'             => 'java:/datasources/heliopsis',
      'transaction-isolation' => 'TRANSACTION_SERIALIZABLE',
      'user-name'             => $username,
      'password'              => $password,
    },
    require => Wildfly::Datasources::Driver['Driver postgresql'],
  }
}
