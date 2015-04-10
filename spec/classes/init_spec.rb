require 'spec_helper'
describe 'pe_satellite' do

  context 'with defaults for all parameters' do
    it { should contain_class('pe_satellite') }
  end
end
