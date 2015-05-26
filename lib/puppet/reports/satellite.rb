require 'puppet/util/satellite'

Puppet::Reports.register_report(:satellite) do
  Puppet.settings.use(:reporting)
  desc "Sends reports directly to Satellite"

  include Puppet::Util::Satellite

  def process
    begin
      # check for report metrics
      raise(Puppet::ParseError, "Invalid report: can't find metrics information for #{self.host}") if self.metrics.nil?

      body = {'report' => generate_report}

      Puppet.info "Submitting report to #{satellite_url}"
      submit_request '/api/reports', body
    rescue Exception => e
      raise Puppet::Error, "Could not send report to Satellite: #{e}\n#{e.backtrace}"
    end
  end
end
