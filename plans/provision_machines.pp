plan satellite_pe_tools::provision_machines(
) {
  run_task('provision::provision_service', 'localhost', action => 'provision', platform => 'centos-7', inventory => './', vars => 'role: ps')
  run_task('provision::provision_service', 'localhost', action => 'provision', platform => 'redhat-7', inventory => './', vars => 'role: satellite')
}
