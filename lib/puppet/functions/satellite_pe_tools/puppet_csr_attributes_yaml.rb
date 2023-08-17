# frozen_string_literal: true

# @summary this function populates and returns the yaml file.
# arguments that return string holds is conditional and decided by the the input given to function.
require 'yaml'

Puppet::Functions.create_function(:'satellite_pe_tools::puppet_csr_attributes_yaml') do
  # @param args
  #   Hash host
  #
  # @return String
  #   Generated yaml on the basis of provided values.
  #
  dispatch :puppet_csr_attributes_yaml do
    required_param 'Optional[Any]', :host
    return_type 'Variant[String]'
  end

  def puppet_csr_attributes_yaml(host)
    puppet_registered_extensions = ['pp_uid', 'pp_instance_id', 'pp_image_name', 'pp_preshared_key', 'pp_cost_center',
                                    'pp_product', 'pp_project', 'pp_application', 'pp_service', 'pp_employee', 'pp_created_by', 'pp_environment', 'pp_role',
                                    'pp_software_version', 'pp_department', 'pp_cluster', 'pp_provisioner', 'pp_region', 'pp_datacenter', 'pp_zone',
                                    'pp_network', 'pp_securitypolicy', 'pp_cloudplatform', 'pp_datacenter', 'pp_apptier', 'pp_hostname']

    csr_attributes = { 'custom_attributes' => {}, 'extension_requests' => {} }

    puppet_registered_extensions.each do |extension|
      csr_attributes['extension_requests'][extension] = host.params[extension] if host.params[extension]
    end
    csr_attributes['custom_attributes']['1.2.840.113549.1.9.7'] = host.params['pp_challenge_password'] if host.params['pp_challenge_password']
    csr_attributes.to_yaml
  end
end
