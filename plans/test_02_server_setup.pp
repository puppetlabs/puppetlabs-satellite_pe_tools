plan satellite_pe_tools::test_02_server_setup(
) {
  # get pe-server from inventory file? eg https://puppet.com/docs/bolt/latest/writing_plans.html#collect-facts-from-the-targets
  $server = get_targets('*').filter |$n| { $n.vars['role'] == 'pe' }
  # install pe server
  $params = {
    'pe_settings' => {
      'password' => 'puppetlabs',
      'configure_tuning' => false,
    },
    'version' => '2021.7.4',
  }
  run_plan('deploy_pe::provision_master', $server, $params)
}
