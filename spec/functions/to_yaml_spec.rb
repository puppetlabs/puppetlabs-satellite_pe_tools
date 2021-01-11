# frozen_string_literal: true

require 'spec_helper'

describe 'to_yaml' do
  let(:arg_error) do
    if Puppet::Util::Package.versioncmp(Puppet.version, '6.0.0') < 0
      [ArgumentError, 'expects']
    else
      [Puppet::ParseError, 'Wrong number of arguments']
    end
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
