class git::server::package {
  @package { $git::params::gt_server_package:
    ensure => 'present',
    tag    => 'git-server-packages',
  }
  Package<| tag == 'git-server-packages' |>
}
