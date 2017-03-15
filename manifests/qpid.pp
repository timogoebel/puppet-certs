# Handles Qpid cert configuration
class certs::qpid (

  $hostname   = $::certs::node_fqdn,
  $cname      = $::certs::cname,
  $generate   = $::certs::generate,
  $regenerate = $::certs::regenerate,
  $deploy     = $::certs::deploy,
) inherits certs {

  Exec { logoutput => 'on_failure' }

  $qpid_cert_name = "${certs::qpid::hostname}-qpid-broker"

  cert { $qpid_cert_name:
    ensure        => present,
    hostname      => $::certs::qpid::hostname,
    cname         => concat($::certs::qpid::cname, 'localhost'),
    country       => $::certs::country,
    state         => $::certs::state,
    city          => $::certs::city,
    org           => 'pulp',
    org_unit      => $::certs::org_unit,
    expiration    => $::certs::expiration,
    ca            => Ca[$default_ca_name],
    generate      => $generate,
    regenerate    => $regenerate,
    deploy        => $deploy,
    password_file => $certs::ca_key_password_file,
  }

  if $deploy {
    include ::certs::ssltools::create_nssdb
    $nss_db_password_file = $::certs::ssltools::create_nssdb::nss_db_password_file

    $client_cert            = "${certs::pki_dir}/certs/${qpid_cert_name}.crt"
    $client_key             = "${certs::pki_dir}/private/${qpid_cert_name}.key"
    $pfx_path               = "${certs::pki_dir}/${qpid_cert_name}.pfx"

    Package['qpid-cpp-server'] ->
    Cert[$qpid_cert_name] ~>
    pubkey { $client_cert:
      key_pair => Cert["${::certs::qpid::hostname}-qpid-broker"],
    } ~>
    privkey { $client_key:
      key_pair => Cert["${::certs::qpid::hostname}-qpid-broker"],
    } ~>
    file { $client_key:
      ensure => file,
      owner  => 'root',
      group  => $::certs::qpidd_group,
      mode   => '0440',
    } ~>
    Class['::certs::ssltools::create_nssdb'] ~>
    certs::ssltools::certutil { 'ca':
      nss_db_dir  => $::certs::nss_db_dir,
      client_cert => $::certs::ca_cert,
      trustargs   => 'TCu,Cu,Tuw',
      refreshonly => true,
    } ~>
    certs::ssltools::certutil { 'broker':
      nss_db_dir  => $::certs::nss_db_dir,
      client_cert => $client_cert,
      refreshonly => true,
    } ~>
    exec { 'generate-pfx-for-nss-db':
      command     => "openssl pkcs12 -in ${client_cert} -inkey ${client_key} -export -out '${pfx_path}' -password 'file:${nss_db_password_file}'",
      path        => '/usr/bin',
      refreshonly => true,
    } ~>
    exec { 'add-private-key-to-nss-db':
      command     => "pk12util -i '${pfx_path}' -d '${::certs::nss_db_dir}' -w '${nss_db_password_file}' -k '${nss_db_password_file}'",
      path        => '/usr/bin',
      refreshonly => true,
    } ~>
    Service['qpidd']

    Pubkey[$::certs::ca_cert] ~> Certs::Ssltools::Certutil['ca']
    Pubkey[$client_cert] ~> Certs::Ssltools::Certutil['broker']
  }

}
