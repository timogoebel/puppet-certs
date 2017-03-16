require 'spec_helper'

describe 'certs::foreman_proxy_content' do
  let :facts do
    on_supported_os['redhat-7-x86_64']
  end

  let :pre_condition do
    "
service{ 'foreman-proxy': }
package{ 'qpid-cpp-server': }
service{ 'qpidd': }
class { 'puppet':
  agent => false,
  server => true,
}
    "
  end

  let :params do
    {
      :certs_tar => '/tmp/tar'
    }
  end

  describe 'with default parameters' do
    it { should compile.with_all_deps }
  end
end