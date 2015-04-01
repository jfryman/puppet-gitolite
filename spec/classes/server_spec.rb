require 'spec_helper'
describe 'gitolite::server' do

  let :pre_condition do
    'class { "gitolite::params": }'
  end

  context 'on RedHat operating systems' do

    let(:facts) {
      {
          :operatingsystem => 'RedHat',
          :fqdn            => 'repo.example.com',
          :domain          => 'example.com',
      }
    }

    context 'without mandatory ssh_key' do
      it {
        expect { should contain_class('gitolite::server') }.to raise_error(Puppet::Error, /Must pass ssh_key to Class\[Gitolite::Server\]/)
      }
    end

    context 'with ssh_key' do
      let (:params) { {:ssh_key => 'AAAA...'} }
      it { should contain_class('gitolite::server') }
      it { should contain_class('gitolite::server::package').that_comes_before('Class[gitolite::server::config]') }
      it { should contain_class('gitolite::server::config').with({
          :site_name => 'repo.example.com Git Repository',
          :vhost     => 'git.example.com',
        })
      }

      context 'with site_name' do
        let (:params) {
          {
              :ssh_key   => 'AAAA...',
              :site_name => 'site_name',
          }
        }
        it { should contain_class('gitolite::server::config').with_site_name('site_name') }
      end

      context 'with vhost' do
        let (:params) {
          {
              :ssh_key => 'AAAA...',
              :vhost   => 'vhost',
          }
        }
        it { should contain_class('gitolite::server::config').with_vhost('vhost') }
      end

    end
  end

end
