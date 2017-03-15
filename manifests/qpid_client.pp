# Pulp Master Certs configuration
class certs::qpid_client (

  $hostname   = $::certs::node_fqdn,
  $cname      = $::certs::cname,
  $generate   = $::certs::generate,
  $regenerate = $::certs::regenerate,
  $deploy     = $::certs::deploy,

  $messaging_client_cert = $certs::params::messaging_client_cert

) inherits certs {

  cert { "${hostname}-qpid-client-cert":
    hostname      => $hostname,
    cname         => $cname,
    common_name   => 'pulp-qpid-client-cert',
    purpose       => client,
    country       => $::certs::country,
    state         => $::certs::state,
    city          => $::certs::city,
    org           => 'PULP',
    org_unit      => $::certs::org_unit,
    expiration    => $::certs::expiration,
    ca            => Ca[$default_ca_name],
    generate      => $generate,
    regenerate    => $regenerate,
    deploy        => $deploy,
    password_file => $::certs::ca_key_password_file,
  }

  if $deploy {

    Cert["${hostname}-qpid-client-cert"] ~>
    key_bundle { $messaging_client_cert:
      key_pair => Cert["${hostname}-qpid-client-cert"],
    } ~>
    file { $messaging_client_cert:
      owner => 'apache',
      group => 'apache',
      mode  => '0640',
    }

  }

}
