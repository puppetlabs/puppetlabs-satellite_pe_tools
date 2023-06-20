# frozen_string_literal: true

require 'json'
require 'rest-client'

def target_roles(roles)
  # rubocop:disable Style/MultilineBlockChain
  inventory_hash['groups'].map { |group|
    group['targets'].map { |node|
      ssh_config = node['config']['ssh'] || {}
      { name: node['uri'], role: node['vars']['role'], username: ssh_config['user'], password: ssh_config['password'] } if roles.include? node['vars']['role']
    }.reject { |val| val.nil? }
  }.flatten
  # rubocop:enable Style/MultilineBlockChain
end

def change_target_host(role)
  ENV['TARGET_HOST'] = role
end

def satellite_post(ip, resource, json_data)
  url = "https://#{ip}/api/v2/"
  full_url = url + resource

  begin
    response = RestClient::Request.new(
      method: :put,
      url: full_url,
      user: 'admin',
      password: 'puppetlabs',
      headers: { accept: :json,
                 content_type: :json },
      payload: json_data,
      verify_ssl: false,
    ).execute
    _results = JSON.parse(response.to_str)
  rescue => e
    puts 'ERROR: ' + e.message
  end
end

def satellite_get(ip, resource)
  url = "https://#{ip}/api/v2/"
  full_url = url + resource

  begin
    response = RestClient::Request.new(
      method: :get,
      url: full_url,
      user: 'admin',
      password: 'puppetlabs',
      verify_ssl: false,
      headers: { accept: :json,
                 content_type: :json },
    ).execute
    _results = JSON.parse(response.to_str)
  rescue => e
    puts 'ERROR: ' + e.message
  end
end

def satellite_get_last_report(satellite_host)
  satellite_get(satellite_host, "hosts/#{satellite_hostname(satellite_host)}/config_reports")['results'].first
end

def satellite_get_facts(satellite_host)
  satellite_get(satellite_host, "hosts/#{satellite_hostname(satellite_host)}/facts")
end

def satellite_hostname(satellite_host)
  @satellite_hostname ||= satellite_get(satellite_host, 'hosts')['results'].last['name']
end

def project_root
  File.expand_path(File.join(File.dirname(__FILE__), '..'))
end
