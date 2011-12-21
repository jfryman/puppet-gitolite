# Class: git::server::config
#
# Description
#  This class is designed to configure the system to use Gitolite and Gitweb
#
# Parameters:
#  $server: Whether to install gitolite in addition to git core tools.
#  $site_name: (default: "fqdn Git Repository") The friendly name displayed on the GitWeb main page. 
#  $manage_apache: flag to determine whether git module also manages Apache configuration
#  $write_apache_conf_to: (file path). This option is used when you want to contain apache
#                         configuration within the git class, but do not want to use the 
#                         puppetlabs-apache module to manage apache. This option takes a file path
#                         and will write the apache template to a specific file on the filesystem. 
#                         REQUIRES: $apache_notify
#  $apache_notify: Reference notification to be used if the git module will manage apache, but the 
#                  puppetlabs-apache module is not going to be used. This takes a type reference 
#                  (e.g.: Class['apache::service'] or Service['apache2']) to send a notification
#                  to the reference to restart an external apache service.
#  $vhost: the virtual host of the apache instance. 
#  $ssh_key: the SSH key used to seed the admin account for gitolite.
# 
# Actions:
#  Configures gitolite/gitweb
#
# Requires:
#  This module has no requirements
#
# Sample Usage:
#  This module should not be called directly.
class git::server::config(
  $site_name,
  $ssh_key,
  $vhost,
  $manage_apache,
  $apache_notify,
  $write_apache_conf_to
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
  file { "${git::params::gt_gitweb_root}${git::params::gt_gitweb_spath}":
    ensure => directory,
  }
  file { "${git::params::gt_gitweb_root}${git::params::gt_gitweb_spath}gitweb.css":
    ensure => file,
    source => 'puppet:///modules/git/gitweb.css',
    require => File["${git::params::gt_gitweb_root}${git::params::gt_gitweb_spath}"],
  } 
  file { "${git::params::gt_gitweb_root}${git::params::gt_gitweb_spath}gitweb.js":
    ensure => file,
    source => 'puppet:///modules/git/gitweb.js',
    require => File["${git::params::gt_gitweb_root}${git::params::gt_gitweb_spath}"],
  }
  
  # Flag modifier to allow user to choose whether to use 
  # puppetlabs-apache module to manage apache config
  # -JDF (12/1/2011)
  if $manage_apache == 'true' {
    # This flag allows other non- puppetlabs-apache modules to still be managed by this module
    # Based on code provided by justone. Ref: https://github.com/jfryman/puppet-gitolite/pull/2
    # -JDF (12/1/2011)
    if $write_apache_conf_to != '' {
      if $apache_notify == '' { fail('Cannot properly manage Apache if a refresh reference is not specified') }
      else {
        file { $write_apache_conf_to:
          ensure  => file,
          content => template('git/gitweb-apache-vhost.conf.erb'),
          notify  => $apache_notify,
          require => [ File["/etc/gitweb.conf"], File["${git::params::gt_httpd_conf_dir}/git.conf"] ],
        }
      }
    }
    else {
      # By default, use the puppetlabs-apache module to manage Apache
      apache::vhost { $vhost:
        port     => '80',
        docroot  => $git::params::gt_repo_dir,
        ssl      => 'false',
        template => 'git/gitweb-apache-vhost.conf.erb',
        priority => '99',
        require  => [ File["/etc/gitweb.conf"], File["${git::params::gt_httpd_conf_dir}/git.conf"] ],
      } 
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
