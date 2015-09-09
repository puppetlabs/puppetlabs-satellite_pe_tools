require 'spec_helper'
describe 'pe_satellite' do

  context 'with defaults for all parameters' do
	let(:params) {{ :satellite_url => 'https://127.0.0.1' }}
	it { should contain_class('pe_satellite') }
  end
end
