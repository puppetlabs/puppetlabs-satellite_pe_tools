# frozen_string_literal: true

require 'spec_helper'

describe 'to_yaml', skip: 'will need to be corrected in https://github.com/puppetlabs/puppetlabs-satellite_pe_tools/pull/208' do
  let(:arg_error) do
    [Puppet::ParseError, 'Wrong number of arguments']
  end

  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params.and_raise_error(arg_error[0], %r{#{arg_error[1]}}) }
  it { is_expected.to run.with_params(1, 2).and_raise_error(arg_error[0], %r{#{arg_error[1]}}) }
  it { is_expected.to run.with_params('').and_return("--- ''\n") }
  it {
    is_expected.to run.with_params(['name' => 'bob', 'details' => { 'age' => 247, 'height' => 476 }]).and_return(
      "---\n- name: bob\n  details:\n    age: 247\n    height: 476\n",
    )
  }
end
