# Pulp Client Certs
class certs::pulp_client (
  $hostname    = $::certs::node_fqdn,
  $cname       = $::certs::cname,
  $generate    = $::certs::generate,
  $regenerate  = $::certs::regenerate,
  $deploy      = $::certs::deploy,
  $common_name = 'admin',
) inherits certs {

  $client_cert_name = 'pulp-client'
  $client_cert      = "${::certs::pki_dir}/certs/${client_cert_name}.crt"
  $client_key       = "${::certs::pki_dir}/private/${client_cert_name}.key"
  $ssl_ca_cert      = $::certs::ca_cert

  cert { $client_cert_name:
    hostname      => $hostname,
    cname         => $cname,
    common_name   => $common_name,
    purpose       => client,
    country       => $::certs::country,
    state         => $::certs::state,
    city          => $::certs::city,
    org           => 'PULP',
    org_unit      => 'NODES',
    expiration    => $::certs::expiration,
    ca            => Ca[$default_ca_name],
    generate      => $generate,
    regenerate    => $regenerate,
    deploy        => $deploy,
    password_file => $::certs::ca_key_password_file,
  }

  if $deploy {
    Cert[$client_cert_name] ~>
    pubkey { $client_cert:
      key_pair => Cert[$client_cert_name],
    } ~>
    privkey { $client_key:
      key_pair => Cert[$client_cert_name],
    } ~>
    file { $client_key:
      group => $certs::group,
      owner => 'root',
      mode  => '0440',
    }
  }

}
