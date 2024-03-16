# == Class: profile::puppetmaster::tuning
#
class profile::puppetmaster::tuning {
  # Take the total system memory
  $memory_mb = (($::memory['system']['total_bytes'] / 1024) / 1024)

  # How much memory to leave for the system
  $reserved_memory = $memory_mb / 8

  # Subtract some memory to leave for the system
  $available_memory = $memory_mb - $reserved_memory

  # Calculate the subsystem memory split
  $console_services_memory_proportion       = 0.2
  $orchestration_services_memory_proportion = 0.2
  $puppetdb_memory_proportion               = 0.2
  $activemq_memory_proportion               = 0.4

  # How much total memory should be allocated to the subsystems
  $subsystem_base_memory = 1280

  # Calculate how much the puppetserver and jrubies are going to need
  $max_active_instances = $::processors['count']
  $puppetserver_optimal_memory = (512 + ($max_active_instances * 512))

  # Calculate how much memory we have to play with given:
  #   - Puppetserver has optimal memory
  #   - Everything else has base
  $unallocated_memory_base = ($memory_mb - $reserved_memory
                                    - $puppetserver_optimal_memory
                                    - $subsystem_base_memory)

  # Double the subsystem memory if possible
  if ($unallocated_memory_base > $subsystem_base_memory) {
    $subsystem_memory = $subsystem_base_memory * 2
  } else {
    $subsystem_memory = $subsystem_base_memory
  }

  # Finally: Set up all the variables
  $console_services_memory       = Integer($subsystem_memory * $console_services_memory_proportion)
  $orchestration_services_memory = Integer($subsystem_memory * $orchestration_services_memory_proportion)
  $puppetdb_memory               = Integer($subsystem_memory * $puppetdb_memory_proportion)
  $activemq_memory               = Integer($subsystem_memory * $activemq_memory_proportion)
  $puppetserver_memory           = Integer($puppetserver_optimal_memory)

  # TODO: Deal with overallocation

  # Final config steps
  $pe_master_group       = node_groups('PE Master')
  $pe_console_group      = node_groups('PE Console')
  $pe_orchestrator_group = node_groups('PE Orchestrator')
  $pe_puppetdb_group     = node_groups('PE PuppetDB')
  $pe_activemq_group     = node_groups('PE ActiveMQ Broker')

  $pe_master_group_additions = {
    'puppet_enterprise::profile::master' => {
      'java_args' => {
        'Xmx' => "${puppetserver_memory}m",
        'Xms' => "${puppetserver_memory}m"
      }
    }
  }

  $pe_console_group_additions = {
    'puppet_enterprise::profile::console' => {
      'java_args' => {
        'Xmx' => "${console_services_memory}m",
        'Xms' => "${console_services_memory}m"
      }
    }
  }

  $pe_orchestrator_group_additions = {
    'puppet_enterprise::profile::orchestrator' => {
      'java_args' => {
        'Xmx' => "${orchestration_services_memory}m",
        'Xms' => "${orchestration_services_memory}m"
      }
    }
  }

  $pe_puppetdb_group_additions = {
    'puppet_enterprise::profile::puppetdb' => {
      'java_args' => {
        'Xmx' => "${puppetdb_memory}m",
        'Xms' => "${puppetdb_memory}m"
      }
    }
  }

  # lint:ignore:only_variable_string
  $pe_activemq_group_additions = {
    'puppet_enterprise::profile::amq::broker' => {
      'heap_mb' => "${activemq_memory}"
    }
  }
  # lint:endignore

  node_group { 'PE Master':
    ensure  => present,
    classes => deep_merge($pe_master_group['PE Master']['classes'],$pe_master_group_additions),
    parent  => 'PE Infrastructure',
    require => Package['puppetclassify_server'],
  }

  node_group { 'PE Console':
    ensure  => present,
    classes => deep_merge($pe_console_group['PE Console']['classes'],$pe_console_group_additions),
    parent  => 'PE Infrastructure',
    require => Package['puppetclassify_server'],
  }

  node_group { 'PE Orchestrator':
    ensure  => present,
    classes => deep_merge($pe_orchestrator_group['PE Orchestrator']['classes'],$pe_orchestrator_group_additions),
    parent  => 'PE Infrastructure',
    require => Package['puppetclassify_server'],
  }

  node_group { 'PE PuppetDB':
    ensure  => present,
    classes => deep_merge($pe_puppetdb_group['PE PuppetDB']['classes'],$pe_puppetdb_group_additions),
    parent  => 'PE Infrastructure',
    require => Package['puppetclassify_server'],
  }

  node_group { 'PE ActiveMQ Broker':
    ensure  => present,
    classes => deep_merge($pe_activemq_group['PE ActiveMQ Broker']['classes'],$pe_activemq_group_additions),
    parent  => 'PE Infrastructure',
    require => Package['puppetclassify_server'],
  }

  Pe_hocon_setting <| title == 'jruby-puppet.max-active-instances' |> {
    ensure => present,
    value  => $max_active_instances,
  }
}
