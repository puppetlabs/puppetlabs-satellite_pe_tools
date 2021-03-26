plan satellite_pe_tools::provision_machines(
 Optional[Array] $os_list= ['rhel-7']
) {
  run_task('provision::provision_service', 'localhost', action => 'provision', platform => 'centos-7', inventory => './', vars => 'role: ps')
  
  $os_list.each |String $os| {
    run_task('provision::provision_service', 'localhost', action => 'provision', platform => $os, inventory => './', vars => 'role: satellite')
  }
}
