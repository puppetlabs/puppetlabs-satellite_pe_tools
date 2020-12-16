# frozen_string_literal: true

# parse_url.rb
module Puppet::Parser::Functions
  newfunction(:parse_url, type: :rvalue, doc: <<-EOS
    @return  This function parses a given URL and provides a hash of the parsed data.
    EOS
             ) do |arguments|

    if arguments.size != 1
      raise(Puppet::ParseError, 'parseyaml(): Wrong number of arguments ' \
        "given #{arguments.size} for 1")
    end

    require 'uri'

    parsed = URI.parse(arguments[0])
    hostname = parsed.hostname
    password = parsed.password
    path = parsed.path
    port = parsed.port
    query = parsed.query
    user = parsed.user

    { 'hostname' => hostname, 'password' => password, 'path' => path, 'port' => port, 'query' => query, 'user' => user }
  end
end

# vim: set ts=2 sw=2 et :
