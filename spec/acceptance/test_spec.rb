require 'spec_helper_acceptance'

terminus_config = '/config/scripts/facts_terminus_config.sh'
manifest_location = '/etc/puppetlabs/code/environments/production/manifests/site.pp'

describe 'satellite_pe_tools tests' do
  # Defaults to the first satellite found
  satellite_host = target_roles('satellite')[0][:name]
  master_host = ENV['TARGET_HOST']
  before(:all) do
    satellite_update_setting(satellite_host, 'trusted_puppetmaster_hosts', Array(master_host))
    Helper.instance.bolt_run_script("#{project_root}#{terminus_config}")
    Helper.instance.run_shell('service pe-puppetserver restart')
    # `puppet agent -t` returns a 2 for changes made which run_shell takes as a failure
    Helper.instance.run_shell('puppet agent -t', expect_failures: true)
  end

  context 'reports' do
    it 'applies' do
      manifest_str = "cat <<EOF > #{manifest_location}
          node default {
            class {'satellite_pe_tools':
              satellite_url => 'https://#{satellite_host}',
              verify_satellite_certificate => true,
              ssl_key  => '/etc/puppetlabs/puppet/ssl/satellite/#{master_host}-puppet-client.key',
              ssl_cert => '/etc/puppetlabs/puppet/ssl/satellite/#{master_host}-puppet-client.crt',
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

    it 'contains the report text in Satellite' do
      expect(satellite_get_last_report(satellite_host, master_host).to_s).to match(%r{This is a test from Puppet to Satellite})
    end
  end

  context 'facts' do
    it 'applies' do
      manifest_str = "cat <<EOF > #{manifest_location}
          node default {
            class {'satellite_pe_tools':
              satellite_url => 'https://#{satellite_host}',
              verify_satellite_certificate => true,
              ssl_key  => '/etc/puppetlabs/puppet/ssl/satellite/#{master_host}-puppet-client.key',
              ssl_cert => '/etc/puppetlabs/puppet/ssl/satellite/#{master_host}-puppet-client.crt',
            }
          }
EOF"

      Helper.instance.run_shell(manifest_str)
      # `puppet agent -t` returns a 2 for changes made which run_shell takes as a failure
      Helper.instance.run_shell('puppet agent -t', expect_failures: true)
    end

    it 'contains the fact text in Satellite' do
      expect(satellite_get_facts(satellite_host, master_host)['total']).not_to eq(0)
    end
  end
end
