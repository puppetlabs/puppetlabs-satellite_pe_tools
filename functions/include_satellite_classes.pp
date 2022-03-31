function satellite_pe_tools::include_satellite_classes() {
  # Get the hash of satellite classes, if it exists.
  $sat_classes = Hash(pick(getvar('trusted.external.satellite.classes'), {}))

  # Split the hash of satellite classes by classes with parameters, and classes
  # without parameters (in that order).
  $sat_classes_split = $sat_classes.partition |$name,$params| { !$params.empty() }

  # Use create_resources to declare classes resource-style if they have
  # parameters specified
  create_resources('class', Hash($sat_classes_split[0]))

  # Use include on the classes without parameters specified
  include(Hash($sat_classes_split[1]).keys)

  # Return a resource array of all classes
  Class[$sat_classes.keys]
}
