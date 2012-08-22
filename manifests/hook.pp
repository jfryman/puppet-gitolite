define gitolite::hook {
  $repo = $name

  File {
    owner => $gitolite::params::gt_uid,
    group => $gitolite::params::gt_gid,
  }

  file { "${gitolite::params::gt_repo_dir}/${repo}.git":
    ensure => directory,
    mode   => '0755',
  }
  file { "${gitolite::params::gt_repo_dir}/${repo}.git/hooks":
    ensure  => directory,
    recurse => true,
    source  => "puppet:///modules/${gitolite::params::gt_hooks_module}/${repo}",
    require => Class['gitolite::server']
  }
}
