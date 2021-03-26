plan satellite_pe_tools::agents_setup(
  Optional[String] $collection = 'puppet7-nightly'
) {
  # get pe_server ?
  $server = get_targets('*').filter |$n| { $n.vars['role'] == 'ps' }

  # get agents ?
  $agents = get_targets('*').filter |$n| { $n.vars['role'] != 'ps' }

  # install agents
  run_task('puppet_agent::install', $agents, { 'collection' => $collection })

  # set the server
  $server_fqdn = run_command('facter fqdn', $server).to_data[0]['value']['stdout']
  run_task('puppet_conf', $agents, action => 'set', section => 'main', setting => 'server', value => $server_fqdn)

  catch_errors() || {
    run_command('systemctl start puppet', $agents, '_catch_errors' => true)
    run_command('systemctl enable puppet', $agents, '_catch_errors' => true)
  }

  # request signature
  run_command('puppet agent -t', $agents, '_catch_errors' => true)

  # sign all requests
  run_command('puppetserver ca sign --all', $server, '_catch_errors' => true)
}
