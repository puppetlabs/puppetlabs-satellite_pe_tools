# frozen_string_literal: true

require 'helper'
require ENV['INTEGRATION_TESTS'] ? 'integration_helper' : 'spec_helper_acceptance'

terminus_config = '/config/scripts/facts_terminus_config.sh'
manifest_location = '/etc/puppetlabs/code/environments/production/manifests/site.pp'

describe 'satellite_pe_tools tests', :integration do
  server_host = target_roles('pe')[0][:name]
  satellite_host = target_roles('satellite')[0][:name]
  before(:all) do
    change_target_host(server_host)
    Helper.instance.bolt_run_script("#{project_root}#{terminus_config}")
    Helper.instance.run_shell("sed -i 's/#{server_host}/#{satellite_host}/g' /etc/puppetlabs/puppet/puppet.conf", expect_failures: true)
    Helper.instance.run_shell('puppet agent -t', expect_failures: true)
  end

  context 'reports' do
    it 'applies' do
      manifest_str = "cat <<EOF > #{manifest_location}
          node default {
            class {'satellite_pe_tools':
              satellite_url => 'https://#{satellite_host}',
              verify_satellite_certificate => true,
              ssl_key  => '/etc/puppetlabs/puppet/ssl/satellite/#{server_host}-puppet-client.key',
              ssl_cert => '/etc/puppetlabs/puppet/ssl/satellite/#{server_host}-puppet-client.crt',
            }

            notify {'This is a test from Puppet to Satellite':
              require => Class['satellite_pe_tools']
            }
          }
EOF"

      Helper.instance.run_shell(manifest_str)
      # `puppet agent -t` returns a 2 for changes made which run_shell takes as a failure
      Helper.instance.run_shell('puppet agent -t', expect_failures: true)
    end

    xit 'contains the report text in Satellite' do
      expect(satellite_get_last_report(satellite_host).to_s).to match(%r{This is a test from Puppet to Satellite})
    end
  end

  context 'facts' do
    it 'applies' do
      manifest_str = "cat <<EOF > #{manifest_location}
          node default {
            class {'satellite_pe_tools':
              satellite_url => 'https://#{satellite_host}',
              verify_satellite_certificate => true,
              ssl_key  => '/etc/puppetlabs/puppet/ssl/satellite/#{server_host}-puppet-client.key',
              ssl_cert => '/etc/puppetlabs/puppet/ssl/satellite/#{server_host}-puppet-client.crt',
            }
          }
EOF"

      Helper.instance.run_shell(manifest_str)
      # `puppet agent -t` returns a 2 for changes made which run_shell takes as a failure
      Helper.instance.run_shell('puppet agent -t', expect_failures: true)
    end

    it 'contains the fact text in Satellite' do
      expect(satellite_get_facts(satellite_host)['total']).not_to eq(0)
    end
  end
end
