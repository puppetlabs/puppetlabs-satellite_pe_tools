plan satellite_pe_tools::test_01_provision(
) {
  # provision server machine, set role 
  run_task('provision::provision_service', 'localhost', action => 'provision', platform => 'centos-stream-8', vars => 'role: pe')
  # provision satellite
  run_task('provision::provision_service', 'localhost', action => 'provision', platform => 'rhel-8', vars => 'role: satellite')
}
