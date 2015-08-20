require 'spec_helper_acceptance'

describe 'pe_satellite report tests' do
  before(:all) do
    satellite_update_setting("#{hosts_as('satellite').first["ip"]}", "restrict_registered_puppetmasters", false)
    
    pp = <<-EOS
        ini_setting { "satelliteconf1":
          ensure  => present,
          path    => "${::settings::confdir}/puppet.conf",
          section => 'master',
          setting => 'reports',
          value   => 'puppetdb,console,satellite',
        }

        ini_setting { "satelliteconf2":
          ensure  => present,
          path    => "${::settings::confdir}/puppet.conf",
          section => 'user',
          setting => 'reports',
          value   => 'satellite',
        }
        EOS

    apply_manifest(pp, :catch_failures => true)
  end



  it 'applies' do
    pp = <<-EOS
   	 class {'pe_satellite':
       satellite_url => "https://#{hosts_as('satellite').first["ip"]}",
       verify_satellite_certificate => false,
     }

     notify {'This is a test from Puppet to Satellite':
       require => Class['pe_satellite']
     }
   	 EOS

   	 apply_manifest(pp, :catch_failures => true)
   end

   it 'should contain the text in Satellite' do
     expect(satellite_get_last_report("#{hosts_as('satellite').first["ip"]}")).to match(/This is a test from Puppet to Satellite/)
   end
end
