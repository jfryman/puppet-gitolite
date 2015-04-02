require 'spec_helper'
describe 'gitolite::server::config' do

  let :pre_condition do
    'class { "gitolite::params": }'
  end

  context 'on RedHat operating systems' do
    let(:facts) {
      {
        :operatingsystem => 'RedHat',
      }
    }

    context 'with necessary parameters' do
      let (:params) {
        {
            :site_name            => 'test_site_name',
            :ssh_key              => 'ssh_key',
            :vhost                => 'test_vhost',
            :manage_apache        => false,
            :apache_notify        => false,
            :write_apache_conf_to => '',
            :wildrepos            => '',
            :grouplist_pgm        => nil,
            :repo_specific_hooks  => false,
            :local_code           => 'test_local_code',
        }
      }

      it { should contain_class('gitolite::server::config') }
      it { should contain_user('gitolite3').with({
          :home => '/opt/git',
          :gid  => 'gitolite3',
        })
      }
      it { should contain_group('gitolite3').with({
          :members => 'apache',
        })
      }

      directories = [
          '/opt/git',
          '/opt/git/repositories',
          '/var/www/git/static/',
      ]
      directories.each do |directory|
        it { should contain_file(directory).with({
              :ensure => 'directory',
              :owner  => 'gitolite3',
              :group  => 'gitolite3',
              :mode   => '0644',
          })
        }
      end

      it { should contain_file('/etc/httpd/conf.d/git.conf').with_ensure('absent') }
      it { should contain_file('/etc/gitweb.conf').
        with_content(/ENV\{HOME\} = \"\/opt\/git\"/).
        with_content(/\$projectroot = \"\/opt\/git\/repositories\"/).
        with_content(/\$projects_list = \"\/opt\/git\/projects.list\"/).
        with_content(/\$stylesheet = \"static\/gitweb.css\"/).
        with_content(/@git_base_url_list.*ssh.*gitolite3.*test_vhost", "http:\/\/test_vhost"\);/).
        with_content(/site_name = "test_site_name"/)
      }

      it { should contain_file('/opt/git/.bash_history').with_ensure('absent') }
      it { should contain_file('gitolite-key').with({
            :path    => '/opt/git/gitolite.pub',
            :content => 'ssh_key',
        }).that_comes_before('Exec[install-gitolite]')
      }
      it { should contain_exec('install-gitolite').with({
            :command     => 'gitolite setup -pk /opt/git/gitolite.pub',
            :creates     => '/opt/git/projects.list',
            :cwd         => '/opt/git',
            :user        => 'gitolite3',
            :environment => 'HOME=/opt/git',
        }).that_comes_before('File[/opt/git/projects.list]')
      }
      it { should contain_file('/opt/git/projects.list').with_mode('0640') }
      it { should contain_file('gitolite-config').with_path('/opt/git/.gitolite.rc').
          with_content(/LOCAL_CODE.*test_local_code/).
          with_content(/#'repo-specific-hooks'/).
          with_content(/#'no-create-on-read'/).
          with_content(/#'no-auto-create'/).
          that_comes_before('Exec[install-gitolite]')
      }
    end

  end

  context 'on Debian operating systems' do
    let(:facts) {
      {
          :operatingsystem => 'Debian',
      }
    }

    context 'with necessary parameters' do
      let (:params) {
        {
            :site_name            => 'test_site_name',
            :ssh_key              => 'ssh_key',
            :vhost                => 'test_vhost',
            :manage_apache        => false,
            :apache_notify        => false,
            :write_apache_conf_to => '',
            :wildrepos            => '',
            :grouplist_pgm        => nil,
            :repo_specific_hooks  => false,
            :local_code           => 'test_local_code',
        }
      }

      it { should contain_class('gitolite::server::config') }
      it { should contain_user('gitolite3').with({
            :home => '/opt/git',
            :gid  => 'gitolite3',
        })
      }
      it { should contain_group('gitolite3').with({
          :members => 'www-data',
        })
      }

      directories = [
          '/opt/git',
          '/opt/git/repositories',
          '/usr/share/gitweb/./',
      ]
      directories.each do |directory|
        it { should contain_file(directory).with({
             :ensure => 'directory',
             :owner  => 'gitolite3',
             :group  => 'gitolite3',
             :mode   => '0644',
          })
        }
      end

      it { should contain_file('/etc/apache2/conf.d/git.conf').with_ensure('absent') }
      it { should contain_file('/etc/gitweb.conf').
        with_content(/ENV\{HOME\} = \"\/opt\/git\"/).
        with_content(/\$projectroot = \"\/opt\/git\/repositories\"/).
        with_content(/\$projects_list = \"\/opt\/git\/projects.list\"/).
        with_content(/\$stylesheet = \"\.\/gitweb.css\"/).
        with_content(/@git_base_url_list.*ssh.*gitolite3.*test_vhost", "http:\/\/test_vhost"\);/).
        with_content(/site_name = "test_site_name"/)
      }

      it { should contain_file('/opt/git/.bash_history').with_ensure('absent') }
      it { should contain_file('gitolite-key').with({
          :path    => '/opt/git/gitolite.pub',
          :content => 'ssh_key',
        }).that_comes_before('Exec[install-gitolite]')
      }
      it { should contain_exec('install-gitolite').with({
          :command     => 'gitolite setup -pk /opt/git/gitolite.pub',
          :creates     => '/opt/git/projects.list',
          :cwd         => '/opt/git',
          :user        => 'gitolite3',
          :environment => 'HOME=/opt/git',
        }).that_comes_before('File[/opt/git/projects.list]')
      }
      it { should contain_file('/opt/git/projects.list').with_mode('0640') }
      it { should contain_file('gitolite-config').with_path('/opt/git/.gitolite.rc').
        with_content(/LOCAL_CODE.*test_local_code/).
        with_content(/#'repo-specific-hooks'/).
        with_content(/#'no-create-on-read'/).
        with_content(/#'no-auto-create'/).
        that_comes_before('Exec[install-gitolite]')
      }
    end

  end

end
