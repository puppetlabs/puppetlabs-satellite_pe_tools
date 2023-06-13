plan satellite_pe_tools::server_setup(
  String[1] $install_dir
) {
  # get pe-server from inventory file? eg https://puppet.com/docs/bolt/latest/writing_plans.html#collect-facts-from-the-targets
  $server = get_targets('*').filter |$n| { $n.vars['role'] == 'pe' }
  # download PE
  run_command("gsutil -q cp gs://artifactory-modules/${install_dir}.tar ./", $server)
  # extract PE
  run_command("tar -xf ${install_dir}.tar", $server)
  # run Installer
  run_command("sudo ${install_dir}/puppet-enterprise-installer -y -c ${install_dir}/conf.d/pe.conf", $server)

  run_command('echo "autosign = true" >> /etc/puppetlabs/puppet/puppet.conf', $server)

  # set the ui password
  run_command('sudo puppet infrastructure console_password --password=litmus', $server)
}
