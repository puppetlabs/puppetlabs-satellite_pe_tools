require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

def project_root
  File.expand_path(File.join(File.dirname(__FILE__), '..'))
end

def find_hosts_with_role(role)
  hosts.select { |h| h[:roles].include?(role) }
end

def install_pe_on(role)
  target_hosts = find_hosts_with_role role

  target_hosts.each do |host|
    #process the version files if necessary
    host['pe_dir'] ||= options[:pe_dir]
    host['pe_ver'] = host['pe_ver'] || options['pe_ver'] ||
     Beaker::Options::PEVersionScraper.load_pe_version(host[:pe_dir] || options[:pe_dir], options[:pe_version_file])

    pe_installed = (on host, '[ -d /etc/puppetlabs ]').exit_code == 0
    unless pe_installed
      #send in the global options hash
      do_install host, options
    end
  end
end

def install_satellite_on(role)
  target_hosts = find_hosts_with_role role
  target_hosts.each do |host|
    fqdn = fact_on host, 'fqdn'

    on host, "grep #{fqdn} /etc/hosts || sed -i 's/satellite/#{fqdn} satellite/' /etc/hosts"
    run_script_on host, project_root + '/config/scripts/install_satellite.sh'
  end
end

install_pe_on        'master'
install_satellite_on 'satellite'

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    copy_module_to('master', :source => project_root, :module_name => 'pe_satellite')
  end
end
