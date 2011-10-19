# Gitolite Module

James Fryman <james@frymanet.com>

This module manages Gitolite from within Puppet.

# Quick Start

Install and bootstrap a Gitolite Server instance. Includes 
Gitolite and GitWeb as a viewer

# Requirements
_Puppet Labs Standard Library_
- http://github.com/puppetlabs/puppetlabs-stdlib
_Apache Module_
- http://github.com/puppetlabs/puppetlabs-apache


*Setup the initial Gitolite Admin Keys and bootstrap*
<pre>
  class { 'git::server:
    site_name => "Frymanet.com Git Repository",
    ssh_key   => "ssh-rsa AAAA.......",
    vhost     => 'git.frymanet.com',
  }
</pre>
