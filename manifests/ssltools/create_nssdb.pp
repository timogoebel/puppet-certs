# Creates a nssdb
class certs::ssltools::create_nssdb inherits certs {
  Exec { logoutput => 'on_failure' }

  $nss_db_password_file   = "${certs::nss_db_dir}/nss_db_password-file"
  $nssdb_files            = ["${::certs::nss_db_dir}/cert8.db", "${::certs::nss_db_dir}/key3.db", "${::certs::nss_db_dir}/secmod.db"]

  file { $::certs::nss_db_dir:
    ensure => directory,
    owner  => 'root',
    group  => $::certs::qpidd_group,
    mode   => '0755',
  } ~>
  exec { 'generate-nss-password':
    command => "openssl rand -base64 24 > ${nss_db_password_file}",
    path    => '/usr/bin',
    creates => $nss_db_password_file,
  } ->
  file { $nss_db_password_file:
    ensure => file,
    owner  => 'root',
    group  => $::certs::qpidd_group,
    mode   => '0640',
  } ~>
  exec { 'create-nss-db':
    command => "certutil -N -d '${::certs::nss_db_dir}' -f '${nss_db_password_file}'",
    path    => '/usr/bin',
    creates => $nssdb_files,
  } ~>
  file { $nssdb_files:
    owner => 'root',
    group => $::certs::qpidd_group,
    mode  => '0640',
  }
}
