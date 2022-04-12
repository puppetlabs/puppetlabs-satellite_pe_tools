# frozen_string_literal: true

require 'puppet_litmus'
require 'singleton'

class Helper
  include Singleton
  include PuppetLitmus
end

SUT_DNS_SERVER = '10.240.1.10'
SATELLITE_INSTALL_FILES = 'satellite-6.2.7-rhel-7-x86_64-dvd.iso'

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Defaults to the first server found
    server = target_roles('server')[0][:name]
    # Defaults to the first satellite found
    satellite = target_roles('satellite')[0][:name]

    change_target_host(server)
    # Make sure the VM is using our internal DNS servers
    Helper.instance.run_shell("sed -i 's/nameserver.*$/nameserver #{SUT_DNS_SERVER}/' /etc/resolv.conf")
    sleep(30)
    Helper.instance.run_shell('puppet module install puppetlabs-inifile')
    sleep(30)
    Helper.instance.run_shell('puppet resource package subscription-manager ensure=installed')

    change_target_host(satellite)
    expand_satellite_disk(satellite) if get_provisioner(satellite) == 'vmpooler' # && satellite['disks']
    install_satellite(satellite)
    change_target_host(server)
    generate_and_transfer_satellite_cert_from_sat_to_pe(server, satellite)
  end
end

def change_target_host(role)
  ENV['TARGET_HOST'] = role
end

def inventory_hash
  @inventory_hash ||= Helper.instance.inventory_hash_from_inventory_file
end

def target_roles(roles)
  # rubocop:disable Style/MultilineBlockChain
  inventory_hash['groups'].map { |group|
    group['targets'].map { |node|
      { name: node['uri'], role: node['vars']['role'] } if roles.include? node['vars']['role']
    }.reject { |val| val.nil? }
  }.flatten
  # rubocop:enable Style/MultilineBlockChain
end

def get_provisioner(host)
  # rubocop:disable Style/MultilineBlockChain
  inventory_hash['groups'].map { |group|
    group['targets'].map { |node|
      node['facts']['provisioner'] if host == node['uri']
    }.reject { |val| val.nil? }
  }.flatten
  # rubocop:enable Style/MultilineBlockChain
end

def expand_satellite_disk(_host)
  [0, 1, 2].each do |num|
    Helper.instance.run_shell("echo '- - -' > /sys/class/scsi_host/host#{num}/scan")
  end
  Helper.instance.run_shell('parted -s /dev/sdb mklabel gpt')
  Helper.instance.run_shell('parted -s /dev/sdb mkpart primary 2048 16000')
  Helper.instance.run_shell('mkfs.ext4 /dev/sdb1')
  Helper.instance.run_shell('pvcreate -y /dev/sdb1')
  Helper.instance.run_shell('vgextend -y rhel /dev/sdb1')
  Helper.instance.run_shell('lvextend -l +100%FREE /dev/mapper/rhel-root')
  Helper.instance.run_shell('xfs_growfs /dev/mapper/rhel-root')
end

def install_satellite(host)
  Helper.instance.run_shell("grep #{host} /etc/hosts || sed -i 's/satellite/#{host} satellite/' /etc/hosts")
  Helper.instance.run_shell("sed -i 's/nameserver.*$/nameserver #{SUT_DNS_SERVER}/' /etc/resolv.conf")
  sleep(60)
  Helper.instance.bolt_run_script("#{project_root}/config/scripts/redhat_repo.sh")
  # Copy satellite installation files from the GCP cloud storage
  Helper.instance.run_shell("gsutil cp -r gs://artifactory-modules/#{SATELLITE_INSTALL_FILES} /tmp/#{SATELLITE_INSTALL_FILES}")
  Helper.instance.bolt_run_script("#{project_root}/config/scripts/install_satellite.sh")
end

def project_root
  File.expand_path(File.join(File.dirname(__FILE__), '..'))
end

def generate_and_transfer_satellite_cert_from_sat_to_pe(server, satellite)
  # Swap host to satellite
  change_target_host(satellite)

  Helper.instance.run_shell("capsule-certs-generate --capsule-fqdn #{server} --certs-tar \"~/#{server}-certs.tar\"")
  # Copy the SSL certs from Satellite to PE
  Helper.instance.run_shell('[ -d /tmp/ssl-build ] || mv /root/ssl-build /tmp')
  Helper.instance.run_shell('chmod -R 0755 /tmp/ssl-build')

  scp_from(satellite, "/tmp/ssl-build/#{server}/#{server}-puppet-client.crt", project_root.to_s)
  scp_from(satellite, "/tmp/ssl-build/#{server}/#{server}-puppet-client.key", project_root.to_s)

  # Swap host back to server
  change_target_host(server)

  Helper.instance.bolt_upload_file("#{project_root}/#{server}-puppet-client.crt", "/tmp/#{server}-puppet-client.crt")
  Helper.instance.bolt_upload_file("#{project_root}/#{server}-puppet-client.key", "/tmp/#{server}-puppet-client.key")

  Helper.instance.run_shell('mkdir -p /etc/puppetlabs/puppet/ssl/satellite')
  Helper.instance.run_shell("cp /tmp/#{server}-puppet-client.crt /etc/puppetlabs/puppet/ssl/satellite/#{server}-puppet-client.crt")
  Helper.instance.run_shell("cp /tmp/#{server}-puppet-client.key /etc/puppetlabs/puppet/ssl/satellite/#{server}-puppet-client.key")
  Helper.instance.run_shell("chown pe-puppet /etc/puppetlabs/puppet/ssl/satellite/#{server}-puppet-client.crt")
  Helper.instance.run_shell("chown pe-puppet /etc/puppetlabs/puppet/ssl/satellite/#{server}-puppet-client.key")
end

require 'net/ssh'
require 'net/scp'

def scp_from(host, target, local)
  Net::SSH.start(host, 'root', host_key: 'ssh-rsa', keys: ['~/.ssh/id_rsa-acceptance']) do |ssh|
    ssh.scp.download!(target, local)
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

def satellite_update_setting(server, satellite, setting, value)
  change_target_host(satellite)
  Helper.instance.run_shell("hammer --username admin --password puppetlabs settings set --id '#{setting}' --value '#{value}'")
  change_target_host(server)
end

def satellite_get_last_report(satellite_host, server_host)
  satellite_get(satellite_host, "hosts/#{server_host}/reports/last")
end

def satellite_get_facts(satellite_host, server_host)
  satellite_get(satellite_host, "hosts/#{server_host}/facts")
end
