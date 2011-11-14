class git::server::config(
  $site_name,
  $ssh_key,
  $vhost = '',
  $apache_conf = ''
) { 
  File {
    owner => $git::params::gt_uid,
    group => $git::params::gt_gid,
    mode  => '0644',
  }
  Exec {
    path => '/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin',
  }

  # Gitolite User Setup
  user { $git::params::gt_uid:
    ensure  => 'present',
    home    => $git::params::gt_repo_base,
    gid     => $git::params::gt_gid,
    comment => 'git repository hosting',
  }
  group { $git::params::gt_gid:
    ensure  => 'present',
    members => $git::params::gt_httpd_uid,
  }
  # Git Filesystem Repository Setup
  file { $git::params::gt_repo_base:
    ensure => 'directory',
  }
  file { "$git::params::gt_repo_dir":
    ensure  => 'directory',
  }
  file { "${git::params::gt_httpd_conf_dir}/git.conf":
    ensure => 'absent',
  }

  # Gitweb Setup
  file { "/etc/gitweb.conf":
    ensure  => file,
    content => template('git/gitweb.conf.erb'),
  }
  ## add pretty style sheets
  file { "${git::params::gt_gitweb_root}${git::params::gt_gitweb_spath}gitweb.css":
    ensure => file,
    source => 'puppet:///modules/git/gitweb.css',
  } 
  file { "${git::params::gt_gitweb_root}${git::params::gt_gitweb_spath}gitweb.js":
    ensure => file,
    source => 'puppet:///modules/git/gitweb.js',
  }

  if $apache_conf == '' {
    apache::vhost { $vhost:
      port     => '80',
      docroot  => $git::params::gt_repo_dir,
      ssl      => 'false',
      template => 'git/gitweb-apache-vhost.conf.erb',
      priority => '99',
      require  => [ File["/etc/gitweb.conf"], File["${git::params::gt_httpd_conf_dir}/git.conf"] ],
    }
  } else {
    file { $apache_conf:
      content => template('git/gitweb-apache-vhost.conf.erb'),
    }
  }

  # Gitolite Configuration
  file { "${git::params::gt_repo_base}/.bash_history":
    ensure => 'absent',
  }
  file { 'gitolite-key':
    path    => "${git::params::gt_repo_base}/gitolite.pub",
    ensure  => file,
    content => $ssh_key,
  }
  exec { 'install-gitolite':
    command     => "gl-setup -q ${git::params::gt_repo_base}/gitolite.pub",
    creates     => "${git::params::gt_repo_base}/projects.list",
    cwd         => $git::params::gt_repo_base,
    user        => $git::params::gt_uid,
    environment => "HOME=${git::params::gt_repo_base}",
    require     => File['gitolite-key'],
  }
  file { "${git::params::gt_repo_base}/projects.list":
    ensure  => file,
    mode    => '0600',
    require => Exec['install-gitolite'],
  }
  file { 'gitolite-config':
    path    => "${git::params::gt_repo_base}/.gitolite.rc",
    content => template('git/gitolite.rc.erb'),
    before  => Exec['install-gitolite'],
  }
}
