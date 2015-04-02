require 'spec_helper'
describe 'gitolite::client::package' do

  let :pre_condition do
    'class { "gitolite::params": }'
  end

  context 'on RedHat operating systems' do
    let(:facts) {
      {
        :operatingsystem => 'RedHat',
      }
    }
    it { should contain_class('gitolite::client::package') }
    client_packages = [
        'perl-Error',
        'perl-Git',
        'git',
    ]
    client_packages.each do |package|
      it { should contain_package(package) }
    end
  end

  context 'on Debian operating systems' do
    let(:facts) {
      {
        :operatingsystem => 'Debian',
      }
    }
    it { should contain_class('gitolite::client::package') }
    it { should contain_package('git') }
  end

end
