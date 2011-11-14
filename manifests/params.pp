class git::params {
  $gt_uid       = 'gitolite'
  $gt_gid       = 'gitolite'
  $gt_repo_base = '/opt/git'
  $gt_repo_dir  = "${gt_repo_base}/repositories"
  $gt_vhost     = "git.${::domain}"
  $gt_site_name = "${::fqdn} Git Repository"

  case $::operatingsystem {
    fedora,redhat,oel,centos: {
      $gt_client_package = ['perl-Error', 'perl-Git', 'git']
      $gt_server_package = [ 'gitweb', 'gitolite' ]
      $gt_httpd_conf_dir = '/etc/httpd/conf.d'
      $gt_httpd_var_dir  = '/var/log/httpd'
      $gt_httpd_uid      = 'apache'
      $gt_gitweb_root    = '/var/www/git/'
      $gt_gitweb_spath   = 'static/'
      $gt_gitweb_binary  = 'gitweb.cgi'
    }
    debian,ubuntu: {
      $gt_client_package = ['git']
      $gt_server_package = [ 'gitweb', 'gitolite' ]
      $gt_httpd_conf_dir = '/etc/apache2/conf.d'
      $gt_httpd_var_dir  = '/var/log/apache2'
      $gt_httpd_uid      = 'www-data'
      $gt_gitweb_root    = '/usr/share/gitweb/'
      $gt_gitweb_spath   = './'
      $gt_gitweb_binary  = 'index.cgi'
    }
  }
}
