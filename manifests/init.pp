class git(
  $server    = 'false',
  $site_name = '',
  $vhost     = ''
) {
  include stdlib
  include git::params

  anchor { 'git::begin': }
  -> class  { 'git::client': }
  -> anchor { 'git::end': }

  if $server == 'true' {
    class { 'git::server':
      site_name => $site_name,
      vhost     => $vhost,
      require   => Class['git::client'], 
      before    => Anchor['git::end'],
    }
  }
}
