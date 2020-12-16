# frozen_string_literal: true

require 'puppet/util/satellite'
require 'puppet/indirector/facts/puppetdb'

# satellite.rb
class Puppet::Node::Facts::Satellite < Puppet::Node::Facts::Puppetdb
  desc "Save facts to Satellite's Foreman component and PuppetDB.
       It uses PuppetDB to retrieve facts for catalog compilation."

  include Puppet::Util::Satellite

  # Submit facts to Satelite
  def save(request)
    begin
      request_body = { 'certname' => request.key,
                       'facts' => request.instance.values,
                       'name' => request.instance.name }

      Puppet.info "Submitting facts to Satellite at #{satellite_url}"
      submit_request '/api/hosts/facts', request_body
    rescue StandardError => e
      Puppet.err "Could not send facts to Satellite: #{e}\n#{e.backtrace}"
    end

    super(request)
  end
end
