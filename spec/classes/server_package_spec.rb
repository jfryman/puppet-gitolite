require 'spec_helper'
describe 'gitolite::server::package' do

  let :pre_condition do
    'class { "gitolite::params": }'
  end

  context 'on RedHat operating systems' do
    let(:facts) {
      {
        :operatingsystem => 'RedHat',
      }
    }
    it { should contain_class('gitolite::server::package') }
    server_packages = [
        'gitweb',
        'gitolite3',
    ]
    server_packages.each do |package|
      it { should contain_package(package) }
    end
  end

  context 'on Debian operating systems' do
    let(:facts) {
      {
        :operatingsystem => 'Debian',
      }
    }
    it { should contain_class('gitolite::server::package') }
    server_packages = [
        'gitweb',
        'gitolite3',
    ]
    server_packages.each do |package|
      it { should contain_package(package) }
    end
  end

end
