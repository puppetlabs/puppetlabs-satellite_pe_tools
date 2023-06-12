plan satellite_pe_tools::provision(
  Optional[String] $provision_type = 'provision_service',
) {
  # provision server machine, set role 
  run_task("provision::${provision_type}", 'localhost', action => 'provision', platform => 'centos-7', vars => 'role: pe')
  # provision satellite
  run_task("provision::${provision_type}", 'localhost', action => 'provision', platform => 'rhel-7', vars => 'role: satellite')
}
