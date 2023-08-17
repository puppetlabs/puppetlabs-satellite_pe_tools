# frozen_string_literal: true

require 'spec_helper'

describe 'satellite_pe_tools::puppet_csr_attributes_yaml' do
  it 'exists' do
    expect(subject).not_to be_nil
  end

  context 'with custom attributes and extension request should return yaml' do
    it 'returns yaml with custom attributes only' do
      expected_result = "---\ncustom_attributes:\n  1.2.840.113549.1.9.7: '123456'\nextension_requests: {}\n"
      expect(subject).to run.with_params(OpenStruct.new('params' => { 'pp_challenge_password' => '123456' })).and_return(expected_result)
    end

    it 'returns yaml without pp_challenge_password' do
      expected_result = "---\ncustom_attributes: {}\nextension_requests: {}\n"
      expect(subject).to run.with_params(OpenStruct.new('params' => { 'pp' => '123456' })).and_return(expected_result)
    end

    it 'returns yaml with extension request only' do
      expected_result = "---\ncustom_attributes: {}\nextension_requests:\n  pp_uid: '1234'\n  pp_securitypolicy: abc\n"
      expect(subject).to run.with_params(OpenStruct.new('params' => { 'pp_uid' => '1234', 'pp_securitypolicy' => 'abc' })).and_return(expected_result)
    end

    it 'returns yaml with custom attributes and extension request' do
      expected_result = "---\ncustom_attributes:\n  1.2.840.113549.1.9.7: '123456'\nextension_requests:\n  pp_uid: '1234'\n  pp_securitypolicy: abc\n"
      input = { 'pp_challenge_password' => '123456', 'pp_uid' => '1234', 'pp_securitypolicy' => 'abc' }
      expect(subject).to run.with_params(OpenStruct.new('params' => input)).and_return(expected_result)
    end
  end
end
