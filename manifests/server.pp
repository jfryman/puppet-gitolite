class git::server(
  $site_name = '',
  $ssh_key,
  $vhost     = '',
  $apache_conf = ''
) {
  include stdlib
  
  if $site_name == '' { $REAL_site_name = $git::params::gt_site_name } 
  else { $REAL_site_name = $site_name }
  
  if $vhost == '' { $REAL_vhost = $git::params::gt_vhost } 
  else { $REAL_vhost = $vhost }

  anchor { 'git::server::begin': }
  -> class { 'git::server::package': }
  -> class { 'git::server::config': 
    site_name => $REAL_site_name,
    ssh_key   => $ssh_key,
    vhost     => $REAL_vhost,
    apache_conf => $apache_conf,
  }
  -> anchor { 'git::server::end': }
}
