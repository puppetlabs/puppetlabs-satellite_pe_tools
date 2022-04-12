plan satellite_pe_tools::acceptance::get_files() {
  $satellite =  get_targets('*').filter |$n| { $n.vars['role'] == 'satellite' }

  run_command('gsutil cp -r gs://artifactory-modules/satellite-6.2.7-rhel-7-x86_64-dvd.iso /tmp/satellite-6.2.7-rhel-7-x86_64-dvd.iso', $satellite)
}
