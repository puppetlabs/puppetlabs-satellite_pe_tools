# frozen_string_literal: true

require 'puppet/util/satellite'

Puppet::Reports.register_report(:satellite) do
  Puppet.settings.use(:reporting)
  desc 'Sends reports directly to Satellite'

  include Puppet::Util::Satellite

  # Check for report metrics
  def process
    raise(Puppet::ParseError, "Invalid report: can't find metrics information for #{host}") if metrics.nil?

    body = { 'report' => generate_report }

    Puppet.info "Submitting report to #{satellite_url}"
    submit_request '/api/config_reports', body
  rescue StandardError => e
    Puppet.err "Could not send report to Satellite: #{e}\n#{e.backtrace}"
  end
end
