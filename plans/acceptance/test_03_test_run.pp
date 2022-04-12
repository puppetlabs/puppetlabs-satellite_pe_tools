plan satellite_pe_tools::test_03_test_run(
) {
  # get pe-server from inventory file? eg https://puppet.com/docs/bolt/latest/writing_plans.html#collect-facts-from-the-targets
  $server = get_targets('*').filter |$n| { $n.vars['role'] == 'pe' }
  # for each server
  $server.each |$sut| {
    # pass the hostname as the sut, as the task is run locally.
    run_task('provision::run_tests', 'localhost', sut => $sut.name)
  }}
