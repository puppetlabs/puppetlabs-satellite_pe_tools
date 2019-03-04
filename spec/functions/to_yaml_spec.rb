require 'spec_helper'

describe 'to_yaml' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params.and_raise_error(Puppet::ParseError, %r{Wrong number of arguments}) }
  it { is_expected.to run.with_params('').and_return("--- ''\n") }
  it {
    is_expected.to run.with_params(['name' => 'bob', 'details' => { 'age' => 247, 'height' => 476 }]).and_return(
      "---\n- name: bob\n  details:\n    age: 247\n    height: 476\n",
    )
  }
end
