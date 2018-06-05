require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker-pe'

SUT_DNS_SERVER = '10.240.1.10'.freeze

def project_root
  File.expand_path(File.join(File.dirname(__FILE__), '..'))
end

def find_hosts_with_role(role)
  hosts.select { |h| h[:roles].include?(role) }
end

def install_satellite
  target_hosts = find_hosts_with_role 'satellite'
  target_hosts.each do |host|
    fqdn = on(host, 'hostname --fqdn').stdout.strip
    on host, "grep #{fqdn} /etc/hosts || sed -i 's/satellite/#{fqdn} satellite/' /etc/hosts"
    on host, 'service firewalld stop'
    unless host['hypervisor'] == 'vmpooler'
      on host, 'service NetworkManager stop'
      on host, 'chkconfig NetworkManager off'
    end
    on host, "sed -i 's/nameserver.*$/nameserver #{SUT_DNS_SERVER}/' /etc/resolv.conf"
    run_script_on host, project_root + '/config/scripts/redhat_repo.sh'
    run_script_on host, project_root + '/config/scripts/install_satellite.sh'
  end
end

def generate_and_transfer_satellite_cert_from_sat_to_pe
  target_satellite_host = find_hosts_with_role('satellite').first
  target_masters = find_hosts_with_role 'master'

  target_masters.each do |master|
    target_puppet_master_fqdn = on(master, 'facter fqdn').stdout.strip
    on target_satellite_host, "capsule-certs-generate --capsule-fqdn #{target_puppet_master_fqdn} --certs-tar \"~/#{target_puppet_master_fqdn}-certs.tar\""

    # Copy the SSL certs from Satellite to PE
    on(target_satellite_host, '[ -d /tmp/ssl-build ] || mv /root/ssl-build /tmp')
    on(target_satellite_host, 'chmod -R 0755 /tmp/ssl-build')
    scp_from(target_satellite_host, "/tmp/ssl-build/#{target_puppet_master_fqdn}/#{target_puppet_master_fqdn}-puppet-client.crt", project_root + '/')
    scp_from(target_satellite_host, "/tmp/ssl-build/#{target_puppet_master_fqdn}/#{target_puppet_master_fqdn}-puppet-client.key", project_root + '/')
    scp_to(master, project_root + "/#{target_puppet_master_fqdn}-puppet-client.crt", '/tmp/')
    scp_to(master, project_root + "/#{target_puppet_master_fqdn}-puppet-client.key", '/tmp/')

    on master, 'mkdir -p /etc/puppetlabs/puppet/ssl/satellite'
    on master, "cp /tmp/#{target_puppet_master_fqdn}-puppet-client.crt /etc/puppetlabs/puppet/ssl/satellite/#{target_puppet_master_fqdn}-puppet-client.crt"
    on master, "cp /tmp/#{target_puppet_master_fqdn}-puppet-client.key /etc/puppetlabs/puppet/ssl/satellite/#{target_puppet_master_fqdn}-puppet-client.key"
    on master, "chown pe-puppet /etc/puppetlabs/puppet/ssl/satellite/#{target_puppet_master_fqdn}-puppet-client.crt"
    on master, "chown pe-puppet /etc/puppetlabs/puppet/ssl/satellite/#{target_puppet_master_fqdn}-puppet-client.key"
  end
end

def ensure_subscription_manager_installed_on(host)
  on host, puppet('resource package subscription-manager ensure=installed')
end

def expand_satellite_disk(host)
  [0, 1, 2].each do |num|
    on host, "echo '- - -' > /sys/class/scsi_host/host#{num}/scan"
  end
  on host, 'parted -s /dev/sdb mklabel gpt'
  on host, 'parted -s /dev/sdb mkpart primary 2048 16000'
  on host, 'mkfs.ext4 /dev/sdb1'
  on host, 'pvcreate -y /dev/sdb1'
  on host, 'vgextend -y rhel /dev/sdb1'
  on host, 'lvextend -l +100%FREE /dev/mapper/rhel-root'
  on host, 'xfs_growfs /dev/mapper/rhel-root'
end

unless ENV['RS_PROVISION'] == 'no' || ENV['BEAKER_provision'] == 'no'
  master_hosts = find_hosts_with_role('master')
  master_hosts.each do |master|
    # Make sure the VM is using our internal DNS servers
    on master, "sed -i 's/nameserver.*$/nameserver #{SUT_DNS_SERVER}/' /etc/resolv.conf"

    install_pe_on(master, {})
    on master, puppet('module install puppetlabs-inifile'), acceptable_exit_codes: [0, 1]
    ensure_subscription_manager_installed_on master
  end

  satellite_hosts = find_hosts_with_role('satellite')
  satellite_hosts.each do |satellite|
    if satellite['hypervisor'] == 'vmpooler' && satellite['disks']
      expand_satellite_disk satellite
    end
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
    copy_module_to('master', source: project_root, module_name: 'satellite_pe_tools', target_module_path: '/etc/puppetlabs/code/modules')
  end
end

require 'json'
require 'rest-client'

def satellite_post(ip, resource, json_data)
  url = "https://#{ip}/api/v2/"
  full_url = url + resource

  begin
    response = RestClient::Request.new(
      method: :put,
      url: full_url,
      user: 'admin',
      password: 'puppetlabs',
      headers: { accept: :json,
                 content_type: :json },
      payload: json_data,
      verify_ssl: false,
    ).execute
    _results = JSON.parse(response.to_str)
  rescue => e
    puts 'ERROR: ' + e.message
  end
end

def satellite_get(ip, resource)
  url = "https://#{ip}/api/v2/"
  full_url = url + resource

  begin
    response = RestClient::Request.new(
      method: :get,
      url: full_url,
      user: 'admin',
      password: 'puppetlabs',
      verify_ssl: false,
      headers: { accept: :json,
                 content_type: :json },
    ).execute
    _results = JSON.parse(response.to_str)
  rescue => e
    puts 'ERROR: ' + e.message
  end
end

def satellite_update_setting(setting, value)
  on('satellite', "hammer --username admin --password puppetlabs settings set --id '#{setting}' --value '#{value}'")
end

def satellite_get_last_report(satellite_host, test_host)
  satellite_get(satellite_host, "hosts/#{test_host}/reports/last")
end

def satellite_get_facts(satellite_host, test_host)
  satellite_get(satellite_host, "hosts/#{test_host}/facts")
end
