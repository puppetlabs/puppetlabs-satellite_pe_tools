require 'spec_helper'
describe 'satellite_pe_tools' do

  context 'with defaults for all parameters' do
    let(:pre_condition){ "service { 'pe-puppetserver': }"}
    let(:params) {{ :satellite_url => 'https://127.0.0.1' }}
    let(:facts) {{ :osfamily => 'RedHat' }}
    it { should contain_class('satellite_pe_tools') }
  end
end
