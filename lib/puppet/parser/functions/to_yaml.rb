# to_yaml.rb
module Puppet::Parser::Functions
  newfunction(:to_yaml, type: :rvalue, doc: <<-EOS
      This function takes a data structure and turns it into yaml
    EOS
             ) do |arguments|

    if arguments.size != 1
      raise(Puppet::ParseError, 'parseyaml(): Wrong number of arguments ' \
        "given #{arguments.size} for 1")
    end

    require 'yaml'

    arguments[0].to_yaml
  end
end

# vim: set ts=2 sw=2 et :
