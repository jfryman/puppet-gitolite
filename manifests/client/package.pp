class git::client::package {
  @package { $git::params::gt_client_package:
    ensure => 'present',
    tag    => 'git-client-package',
  }
  Package<| tag == 'git-client-package' |>
}
