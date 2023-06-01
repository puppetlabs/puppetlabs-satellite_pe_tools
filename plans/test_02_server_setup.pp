plan satellite_pe_tools::test_02_server_setup(
) {
  # get pe-server from inventory file? eg https://puppet.com/docs/bolt/latest/writing_plans.html#collect-facts-from-the-targets
  $server = get_targets('*').filter |$n| { $n.vars['role'] == 'pe' }
  # install pe server
  $params = {
    'primary_host' => $server,
    'console_password' => 'litmus',
    'version' => '2021.7.4',
  }

  $server.each |$sut| {
    run_command("iptables -t nat -A OUTPUT -p tcp -d ${sut.uri} --dport 8140 -j REDIRECT", $sut)
    run_command("iptables -t nat -A OUTPUT -p tcp -d ${sut.uri} --dport 8081 -j REDIRECT", $sut)
    run_command("iptables -t nat -A OUTPUT -p tcp -d ${sut.uri} --dport 4433 -j REDIRECT", $sut)
  }
  run_plan('peadm::install', $params)
}
