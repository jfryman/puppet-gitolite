require 'spec_helper'
describe 'gitolite' do

  context 'on Debian operating systems' do

    let(:facts) { {:operatingsystem => 'Debian'} }

    context 'with defaults for all parameters' do
      it { should contain_class('gitolite') }
      it { should contain_class('gitolite::params') }
      it { should contain_class('gitolite::client') }
      it { should_not contain_class('gitolite::server') }
    end

  end

  context 'on RedHat operating systems' do

    let(:facts) { {:operatingsystem => 'RedHat'} }

    context 'with defaults for all parameters' do
      it { should contain_class('gitolite') }
      it { should contain_class('gitolite::params') }
      it { should contain_class('gitolite::client') }
      it { should_not contain_class('gitolite::server') }
    end

    context 'with server' do
      let (:params) { {:server => true} }
      it { should contain_class('gitolite') }
      it { should contain_class('gitolite::client').that_comes_before('Class[gitolite::server]') }
      it { should contain_class('gitolite::server') }
    end

  end

end
