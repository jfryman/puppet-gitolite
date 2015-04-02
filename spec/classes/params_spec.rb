require 'spec_helper'
describe 'gitolite::params' do

  context 'on Debian operating systems' do
    let(:facts) { {:operatingsystem => 'Debian'} }
    context 'with defaults for all parameters' do
      it { should contain_class('gitolite::params') }
    end
  end

  context 'on Red Hat operating systems' do
    let(:facts) { {:operatingsystem => 'Debian'} }
    context 'with defaults for all parameters' do
      it { should contain_class('gitolite::params') }
    end
  end

end
