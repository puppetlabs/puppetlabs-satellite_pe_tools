# frozen_string_literal: true

require 'helper'
require 'net/scp'
require 'net/ssh'
require 'puppet_litmus'
require 'singleton'

class Helper
  include Singleton
  include PuppetLitmus
end

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Defaults to the first server found
    server = target_roles('pe')[0][:name]
    # Defaults to the first satellite found
    satellite = target_roles('satellite')[0][:name]

    change_target_host(server)
    Helper.instance.run_shell('puppet module install puppetlabs-inifile')
    Helper.instance.run_shell('puppet module install puppetlabs-satellite_pe_tools')
    Helper.instance.run_shell('puppet resource package subscription-manager ensure=installed')

    change_target_host(satellite)
    expand_satellite_disk(satellite) if get_provisioner(satellite) == 'vmpooler' # && satellite['disks']
    # Whitelist Satellite EIP in Puppet Server SG with port 8140
    whitelist_source_range_and_port(server, satellite, 'tcp:8140')
    # Whitelist Puppet EIP in Satellite Service SG with port 443
    whitelist_source_range_and_port(satellite, server, 'tcp:443')
    install_satellite(satellite, server)
    sing_certs(server)
    # run_puppet_agent(satellite)
    change_target_host(server)
    generate_and_transfer_satellite_cert_from_sat_to_pe(server, satellite)
    # Update satellite config
    satellite_update_setting(server, satellite, 'trusted_hosts', Array(server))
    # Register Puppet Node on Satellite
    register_pe_server(satellite, server)
  end
end

def sing_certs(server)
  change_target_host(server)
  Helper.instance.run_shell('puppetserver ca sign --all')
end

def run_puppet_agent(satellite)
  change_target_host(satellite)
  Helper.instance.run_shell('puppet agent -t')
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

def install_satellite(host, server)
  # Add puppet/satellite master host entry
  Helper.instance.run_shell("echo '#{server} puppet' >> /etc/hosts ")
  Helper.instance.run_shell("echo '#{host} satellite' >> /etc/hosts")
  Helper.instance.bolt_run_script("#{project_root}/config/scripts/install_satellite.sh")
end

def whitelist_source_range_and_port(server, source, port)
  change_target_host(server)
  Helper.instance.bolt_run_script("#{project_root}/config/scripts/update_firewall_rules.sh", arguments: ["#{server}/32,#{runner_public_ip}/32,#{source}/32", port])
end

def generate_and_transfer_satellite_cert_from_sat_to_pe(server, satellite)
  # Swap host to satellite
  change_target_host(satellite)

  Helper.instance.run_shell("capsule-certs-generate --foreman-proxy-fqdn #{server} --certs-tar \"~/#{server}-certs.tar\"")
  # Copy the SSL certs from Satellite to PE
  Helper.instance.run_shell('[ -d /tmp/ssl-build ] || mv /root/ssl-build /tmp')
  Helper.instance.run_shell('chmod -R 0755 /tmp/ssl-build')

  satellite_config = target_roles('satellite')[0]
  scp_from(satellite, "/tmp/ssl-build/#{server}/#{server}-puppet-client.crt", project_root.to_s, satellite_config[:username], satellite_config[:password])
  scp_from(satellite, "/tmp/ssl-build/#{server}/#{server}-puppet-client.key", project_root.to_s, satellite_config[:username], satellite_config[:password])

  # Swap host back to server
  change_target_host(server)

  Helper.instance.bolt_upload_file("#{project_root}/#{server}-puppet-client.crt", "/tmp/#{server}-puppet-client.crt")
  Helper.instance.bolt_upload_file("#{project_root}/#{server}-puppet-client.key", "/tmp/#{server}-puppet-client.key")

  Helper.instance.run_shell('mkdir -p /etc/puppetlabs/puppet/ssl/satellite')
  Helper.instance.run_shell('chown pe-puppet:pe-puppet /etc/puppetlabs/puppet/ssl/satellite')
  Helper.instance.run_shell("cp /tmp/#{server}-puppet-client.crt /etc/puppetlabs/puppet/ssl/satellite/#{server}-puppet-client.crt")
  Helper.instance.run_shell("cp /tmp/#{server}-puppet-client.key /etc/puppetlabs/puppet/ssl/satellite/#{server}-puppet-client.key")
  Helper.instance.run_shell("chown pe-puppet /etc/puppetlabs/puppet/ssl/satellite/#{server}-puppet-client.crt")
  Helper.instance.run_shell("chown pe-puppet /etc/puppetlabs/puppet/ssl/satellite/#{server}-puppet-client.key")
end

def scp_from(host, target, local, username, password)
  if username && password
    Net::SSH.start(host, username, password: password) do |ssh|
      ssh.scp.download!(target, local)
    end
  else
    Net::SSH.start(host, 'root', host_key: 'ssh-rsa', keys: ['~/.ssh/id_rsa-acceptance']) do |ssh|
      ssh.scp.download!(target, local)
    end
  end
end

def satellite_update_setting(server, satellite, setting, value)
  change_target_host(satellite)
  Helper.instance.run_shell("hammer --username admin --password puppetlabs settings set --id '#{setting}' --name '#{setting}' --value '#{value}'")
  # Create activation key
  # rubocop:disable Layout/LineLength
  Helper.instance.run_shell("hammer --username admin --password puppetlabs activation-key create --name 'puppetlabs' --unlimited-hosts --description 'Example Stack in the Development Environment' --lifecycle-environment 'Library' --content-view 'Default Organization View' --organization-label Default_Organization")
  # rubocop:enable Layout/LineLength
  # add global host params
  Helper.instance.run_shell("hammer --username admin --password puppetlabs global-parameter set --name puppet_server --value https://#{server}")
  Helper.instance.run_shell('hammer --username admin --password puppetlabs global-parameter set --name enable-puppet7 --value true')
  change_target_host(server)
end

def runner_public_ip
  @runner_public_ip ||= Net::HTTP.get(URI('https://api.ipify.org'))
end

def register_pe_server(satellite, server)
  change_target_host(server)
  Helper.instance.run_shell("curl -ksS -u 'admin:puppetlabs' https://#{satellite}/register > /tmp/register.sh")
  Helper.instance.run_shell("sed -i 's/curl/curl -k/g' /tmp/register.sh")
  Helper.instance.run_shell("sed -i \"s/--activationkey=''/--activationkey='puppetlabs' --force/g\" /tmp/register.sh")
  Helper.instance.run_shell('chmod 755 /tmp/register.sh && /tmp/register.sh')
  Helper.instance.run_shell('/tmp/register.sh')
end

def inventory_hash
  @inventory_hash ||= Helper.instance.inventory_hash_from_inventory_file
end
