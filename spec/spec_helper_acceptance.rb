require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker-pe'

SUT_DNS_SERVER = '10.240.1.10'

def project_root
  File.expand_path(File.join(File.dirname(__FILE__), '..'))
end

def find_hosts_with_role(role)
  hosts.select { |h| h[:roles].include?(role) }
end

def install_satellite
  target_hosts = find_hosts_with_role 'satellite'
  target_hosts.each do |host|
    fqdn = on(host, "hostname --fqdn").stdout.strip
    on host, "grep #{fqdn} /etc/hosts || sed -i 's/satellite/#{fqdn} satellite/' /etc/hosts"
    on host, "service firewalld stop"
    on host, "service NetworkManager stop"
    on host, "chkconfig NetworkManager off"
    on host, "sed -i 's/nameserver.*$/nameserver #{SUT_DNS_SERVER}/' /etc/resolv.conf"
    run_script_on host, project_root + '/config/scripts/redhat_repo.sh'
    run_script_on host, project_root + '/config/scripts/install_satellite.sh'
  end
end

def generate_and_transfer_satellite_cert_from_sat_to_pe
  target_satellite_host = find_hosts_with_role('satellite').first
  target_masters = find_hosts_with_role 'master'

  target_masters.each do |master|
    target_puppet_master_fqdn = on(master, "facter fqdn").stdout.strip
    on target_satellite_host, "sudo capsule-certs-generate --capsule-fqdn #{target_puppet_master_fqdn} --certs-tar \"~/#{target_puppet_master_fqdn}-certs.tar\""

    scp_from(target_satellite_host, "~/ssl-build/#{target_puppet_master_fqdn}/#{target_puppet_master_fqdn}-puppet-client.crt", project_root)
    scp_from(target_satellite_host, "~/ssl-build/#{target_puppet_master_fqdn}/#{target_puppet_master_fqdn}-puppet-client.key", project_root)
    scp_to(master, project_root + "#{target_puppet_master_fqdn}-puppet-client.crt", "~/")
    scp_to(master, project_root + "#{target_puppet_master_fqdn}-puppet-client.key", "~/")
    
    on master, "sudo mkdir -p /etc/puppetlabs/puppet/ssl/satellite"
    on master, "sudo cp ~/#{target_puppet_master_fqdn}-puppet-client.crt /etc/puppetlabs/puppet/ssl/satellite/#{target_puppet_master_fqdn}-puppet-client.crt"
    on master, "sudo cp ~/#{target_puppet_master_fqdn}-puppet-client.key /etc/puppetlabs/puppet/ssl/satellite/#{target_puppet_master_fqdn}-puppet-client.key"
    on master, "sudo chown pe-puppet /etc/puppetlabs/puppet/ssl/satellite/#{target_puppet_master_fqdn}-puppet-client.crt"
    on master, "sudo chown pe-puppet /etc/puppetlabs/puppet/ssl/satellite/#{target_puppet_master_fqdn}-puppet-client.key"
  end
end

def ensure_subscription_manager_installed_on(host)
  on host, 'sudo puppet resource package subscription-manager ensure=installed'
end

unless ENV['RS_PROVISION'] == 'no' or ENV['BEAKER_provision'] == 'no'
  master_hosts = find_hosts_with_role('master')
  master_hosts.each do |master|
    #Make sure the VM is using our internal DNS servers
    on master, "sed -i 's/nameserver.*$/nameserver #{SUT_DNS_SERVER}/' /etc/resolv.conf"

    install_pe_on(master, {})
    on master, puppet('module install puppetlabs-inifile'), { :acceptable_exit_codes => [0,1] }
    ensure_subscription_manager_installed_on master
  end

  install_satellite
  generate_and_transfer_satellite_cert_from_sat_to_pe
end

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    copy_module_to('master', :source => project_root, :module_name => 'satellite_pe_tools', :target_module_path => '/etc/puppetlabs/code/modules')
  end
end

require 'json'
require 'rest-client'

def satellite_post(ip, resource, json_data)
  url = "https://#{ip}/api/v2/"
  full_url = url + resource

  begin
    response = RestClient::Request.new(
      :method => :put,
      :url => full_url,
      :user => "admin",
      :password => "puppetlabs",
      :headers => { :accept => :json,
      :content_type => :json},
      :payload => json_data,
      :verify_ssl => false
    ).execute
    results = JSON.parse(response.to_str)
  rescue => e
    e.response
  end
end

def satellite_get(ip, resource)
  url = "https://#{ip}/api/v2/"
  full_url = url + resource

  begin
    response = RestClient::Request.new(
      :method => :get,
      :url => full_url,
      :user => "admin",
      :password => "puppetlabs",
      :verify_ssl => false,
      :headers => { :accept => :json,
    :content_type => :json }
    ).execute
    results = JSON.parse(response.to_str)
  rescue => e
    e.response
  end
end

def satellite_update_setting(ip, setting, value)
  satellite_post(ip, "settings/#{setting}", JSON.generate(
    {
      "id"=> "#{setting}", 
      "setting" => {"value" => value}
    })
  )
end

def satellite_get_last_report(satellite_host, test_host)
  satellite_get(satellite_host, "hosts/#{test_host}/reports/last")['logs'].join("\n")
end

def satellite_get_facts(satellite_host, test_host)
  satellite_get(satellite_host, "hosts/#{test_host}/facts").to_s
end
