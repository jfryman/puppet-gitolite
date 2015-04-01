require 'spec_helper'
describe 'gitolite::client' do

  context 'on RedHat operating systems' do
    let(:facts) { {:operatingsystem => 'RedHat'} }
    context 'default' do
      it { should contain_class('gitolite::client') }
      it { should contain_class('gitolite::client::package') }
    end
  end

end
