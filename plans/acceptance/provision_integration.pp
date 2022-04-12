# @summary Provisions machines
#
# Provisions machines for integration testing
#
# @example
#   satellite_pe_tools::acceptance::provision_integration
plan satellite_pe_tools::acceptance::provision_integration(
  # Set the provision service
  Optional[String] $using = 'provision_service',
  # Set what machines to use for the server and the satellite
  Optional[String] $server_image = 'centos-7',
  Optional[String] $satellite_image = 'rhel-7'
) {
  # provision server machine, set role 
  run_task("provision::${$using}", 'localhost', action => 'provision', platform => $server_image, vars => 'role: server')
  # provision satellite machine, set role
  run_task("provision::${$using}", 'localhost', action => 'provision', platform => $satellite_image, vars => 'role: satellite')
}
