plan satellite_pe_tools::puppetserver_setup(
) {
  # get server
  $server = get_targets('*').filter |$node| { $node.vars['role'] == 'ps' }

  # install puppetserver and start on master
  run_task(
    'provision::install_puppetserver',
    $server,
    'install and configure server'
  )

  $fqdn = run_command('facter fqdn', $server).to_data[0]['value']['stdout']
  run_task('puppet_conf', $server, action => 'set', section => 'main', setting => 'server', value => $fqdn)

  run_command('systemctl start puppetserver', $server, '_catch_errors' => true)
  run_command('systemctl enable puppetserver', $server, '_catch_errors' => true)
}
