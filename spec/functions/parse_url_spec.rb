# frozen_string_literal: true

require 'spec_helper'

describe 'parse_url' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params.and_raise_error(Puppet::ParseError, %r{Wrong number of arguments}) }
  it { is_expected.to run.with_params('').and_return('hostname' => nil, 'password' => nil, 'path' => '', 'port' => nil, 'query' => nil, 'user' => nil) }

  it {
    expect(subject).to run.with_params('https://satellite.local/somewhere?value=1').and_return(
      'hostname' => 'satellite.local', 'password' => nil, 'path' => '/somewhere', 'port' => 443, 'query' => 'value=1', 'user' => nil,
    )
  }
end
