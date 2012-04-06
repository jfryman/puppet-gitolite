# Class: git::client
#
# This module manages git client management
#
# Parameters:
#
# There are no default parameters for this class.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# This class file is not called directly.
class git::client {
  include stdlib

  anchor { 'git::client::begin': }
  -> class { 'git::client::package': }
  -> anchor { 'git::client::end': }
}
