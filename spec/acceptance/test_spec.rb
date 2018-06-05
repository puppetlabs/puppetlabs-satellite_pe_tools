require 'spec_helper_acceptance'

# The following block is required due to differences in networking
# setup as well as functionality in beaker between vagrant and vmpooler
if default['hypervisor'] =~ %r{vagrant}
  satellite_hostname = hosts_as('satellite').first.name
  satellite_host = on('satellite', "cat /etc/hosts | grep #{satellite_hostname} | tail -1 | awk '{print $1}'").stdout.strip
  master_host = 'master.vm'
else
  satellite_hostname = hosts_as('satellite').first.hostname
  satellite_host = satellite_hostname
  master_host = hosts_as('master').first.hostname
end

if master['pe_dir'] =~ %r{3\.8}
  terminus_config = '/config/scripts/facts_terminus_config-3.sh'
  manifest_location = '/etc/puppetlabs/puppet/environments/production/manifests/site.pp'
else
  terminus_config = '/config/scripts/facts_terminus_config.sh'
  manifest_location = '/etc/puppetlabs/code/environments/production/manifests/site.pp'
end

describe 'satellite_pe_tools tests' do
  before(:all) do
    satellite_update_setting('trusted_puppetmaster_hosts', Array(master_host))
    run_script_on 'master', project_root + terminus_config
    on 'master', 'service pe-puppetserver restart'
    on 'master', 'puppet agent -t', acceptable_exit_codes: [0, 2]
  end

  context 'report tests' do
    it 'applies' do
      manifest_str = "cat <<EOF > #{manifest_location}
          node default {
            class {'satellite_pe_tools':
              satellite_url => 'https://#{satellite_hostname}',
              verify_satellite_certificate => true,
              ssl_key  => '/etc/puppetlabs/puppet/ssl/satellite/#{master_host}-puppet-client.key',
              ssl_cert => '/etc/puppetlabs/puppet/ssl/satellite/#{master_host}-puppet-client.crt',
            }

            notify {'This is a test from Puppet to Satellite':
              require => Class['satellite_pe_tools']
            }
          }
EOF"

      on 'master', manifest_str
      on 'master', 'puppet agent -t', acceptable_exit_codes: [0, 2]
    end

    it 'contains the report text in Satellite' do
      expect(satellite_get_last_report(satellite_host, master_host).to_s).to match(%r{This is a test from Puppet to Satellite})
    end
  end

  context 'facts tests' do
    it 'applies' do
      manifest_str = "cat <<EOF > #{manifest_location}
          node default {
            class {'satellite_pe_tools':
              satellite_url => 'https://#{satellite_hostname}',
              verify_satellite_certificate => true,
              ssl_key  => '/etc/puppetlabs/puppet/ssl/satellite/#{master_host}-puppet-client.key',
              ssl_cert => '/etc/puppetlabs/puppet/ssl/satellite/#{master_host}-puppet-client.crt',
            }
          }
EOF"

      on 'master', manifest_str
      on 'master', 'puppet agent -t', acceptable_exit_codes: [0, 2]
    end

    it 'contains the fact text in Satellite' do
      expect(satellite_get_facts(satellite_host, master_host)['total']).not_to eq(0)
    end
  end
end
