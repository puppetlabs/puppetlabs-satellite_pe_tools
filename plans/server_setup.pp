plan satellite_pe_tools::server_setup(
) {
  # get pe-server from inventory file? eg https://puppet.com/docs/bolt/latest/writing_plans.html#collect-facts-from-the-targets
  $server = get_targets('*').filter |$n| { $n.vars['role'] == 'pe' }

  $install_dir = 'puppet-enterprise-2019.8.13-rc1-154-gb5f3d9c-el-7-x86_64'
  # download PE
  run_command('gsutil -q cp gs://artifactory-modules/puppet-enterprise-2019.8.13-rc1-154-gb5f3d9c-el-7-x86_64.tar ./', $server)
  # extract PE
  run_command('tar -xf puppet-enterprise-2019.8.13-rc1-154-gb5f3d9c-el-7-x86_64.tar', $server)
  # run Installer
  run_command("sudo ${install_dir}/puppet-enterprise-installer -y -c ${install_dir}/conf.d/pe.conf", $server)

  # set the ui password
  run_command('sudo puppet infrastructure console_password --password=litmus', $server)
}
