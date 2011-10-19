class git::client {
  include stdlib

  anchor { 'git::client::begin': }
  -> class { 'git::client::package': }
  -> anchor { 'git::client::end': }
}
