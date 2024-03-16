# Manages CD4PE servers
#
# This profile doesn't actually install CD4PE 4.0 since there isn't a nice
# way top do that yet with Puppet. Instead it exports the load balancer
# endpoints and also sets up  the network so that CD4PE can definitely talk
# to itself via the load balancer
#
# @param dns_name The DNS name that the kubernetes cluster has been configured to use for when people access CD4PE. This will be put into a host entry pointing at the load balancer IP
# @param kubernetes_dns_name The DNS name of the kyubernetes API
class profile::cd4pe::replicated () {
  # Create HAProxy endpoints
  # Balance the CD4PE ports
  @@haproxy::balancermember { "${facts['fqdn']}-cd4pe":
    listening_service => 'cd4pe',
    ports             => '443',
    server_names      => $facts['fqdn'],
    ipaddresses       => $facts['networking']['ip'],
    options           => 'check',
  }

  @@haproxy::balancermember { "${facts['fqdn']}-cd4pe-webhooks":
    listening_service => 'cd4pe-webhooks',
    ports             => '443',
    server_names      => $facts['fqdn'],
    ipaddresses       => $facts['networking']['ip'],
    options           => 'check',
  }

  # Balance the Kubernetes ports too
  @@haproxy::balancermember { "${facts['fqdn']}-k8s-api":
    listening_service => 'k8s-api',
    ports             => '6443',
    server_names      => $facts['fqdn'],
    ipaddresses       => $facts['networking']['ip'],
    options           => 'check',
  }

  @@haproxy::balancermember { "${facts['fqdn']}-kots-console":
    listening_service => 'kots-console',
    ports             => '8800',
    server_names      => $facts['fqdn'],
    ipaddresses       => $facts['networking']['ip'],
    options           => 'check',
  }

  @@haproxy::balancermember { "${facts['fqdn']}-k8s-registry":
    listening_service => 'k8s-registry',
    ports             => '443',
    server_names      => $facts['fqdn'],
    ipaddresses       => $facts['networking']['ip'],
    options           => 'check',
  }
}
