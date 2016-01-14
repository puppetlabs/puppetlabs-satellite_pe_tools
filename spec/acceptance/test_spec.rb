require 'spec_helper_acceptance'

# The following block is required due to differences in networking
# setup as well as functionality in beaker between vagrant and vmpooler
if default['hypervisor'] =~ /vagrant/
  satellite_host = hosts_as('satellite').first["ip"]
  master_host = "master"
else
  satellite_host = hosts_as('satellite').first.hostname
  master_host = hosts_as('master').first.hostname
end

if master['pe_dir'] =~ /3\.8/
  terminus_config = '/config/scripts/facts_terminus_config-3.sh'
  manifest_location = '/etc/puppetlabs/puppet/environments/production/manifests/site.pp'
else
  terminus_config = '/config/scripts/facts_terminus_config.sh'
  manifest_location = '/etc/puppetlabs/code/environments/production/manifests/site.pp'
end

describe 'satellite_pe_tools tests' do
  before(:all) do
    satellite_update_setting(satellite_host, "restrict_registered_puppetmasters", false)
    run_script_on "master", project_root + terminus_config
    on "master", "service pe-puppetserver restart"
    on "master", "puppet agent -t", {:acceptable_exit_codes => [0,2]}
  end

  context 'report tests' do
    it 'applies' do
      manifest_str = "cat <<EOF > #{manifest_location}
          node default {
            class {'satellite_pe_tools':
              satellite_url => 'https://#{satellite_host}',
              verify_satellite_certificate => true,
            }

            notify {'This is a test from Puppet to Satellite':
              require => Class['satellite_pe_tools']
            }
          }
EOF"

      on "master", manifest_str
      on "master", "puppet agent -t", {:acceptable_exit_codes => [0,2]}
    end

    it 'should contain the report text in Satellite' do
      expect(satellite_get_last_report(satellite_host, master_host)).to match(/This is a test from Puppet to Satellite/)
    end
  end

  context 'facts tests' do
    it 'applies' do
      manifest_str = "cat <<EOF > #{manifest_location}
          node default {
            class {'satellite_pe_tools':
              satellite_url => 'https://#{satellite_host}',
              verify_satellite_certificate => true,
            }
          }
EOF"

      on "master", manifest_str
      on "master", "puppet agent -t", {:acceptable_exit_codes => [0,2]}
    end

    it 'should contain the fact text in Satellite' do
      expect(satellite_get_facts(satellite_host, master_host)).to match(/#{hosts_as('master').first.ip}/)
    end
  end
end
