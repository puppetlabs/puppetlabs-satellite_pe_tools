plan satellite_pe_tools::test_01_provision(
) {
  # provision server machine, set role 
  run_task('provision::vmpooler', 'localhost', action => 'provision', platform => 'centos-7-x86_64', inventory => './', vars => 'role: pe')
  # provision satellite
  run_task('provision::vmpooler', 'localhost', action => 'provision', platform => 'redhat-7-x86_64', inventory => './', vars => 'role: satellite')
}
