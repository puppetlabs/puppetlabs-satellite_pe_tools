# frozen_string_literal: true

require 'spec_helper'

describe 'satellite_pe_tools' do
  let(:pre_condition) { "service { 'pe-puppetserver': }" }
  let(:params) { { satellite_url: 'https://127.0.0.1' } }

  on_supported_os.each do |os, facts|
    context "On #{os}" do
      let(:facts) { facts }

      context 'with defaults for all parameters' do
        it { is_expected.to contain_class('satellite_pe_tools') }
        it { is_expected.to contain_ini_subsetting('reports_satellite') }
        it { is_expected.to contain_file('satellite_config_yaml') }
        it { is_expected.to contain_exec('download_install_katello_cert_rpm') }
        it { is_expected.to contain_file('/etc/puppetlabs/puppet/ssl/ca/katello-default-ca.crt') }
      end

      context "with manage_default_ca_cert => false and with os family => 'RedHat'" do
        let(:params) { { satellite_url: 'https://127.0.0.1', manage_default_ca_cert: false } }

        it { is_expected.not_to contain_exec('download_install_katello_cert_rpm') }
        it { is_expected.not_to contain_file('/etc/puppetlabs/puppet/ssl/ca/katello-default-ca.crt') }
      end
    end
  end
end
