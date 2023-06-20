# frozen_string_literal: true

require 'puppet_litmus'
require 'singleton'

class Helper
  include Singleton
  include PuppetLitmus
end

def inventory_hash
  @inventory_hash ||= Helper.instance.inventory_hash_from_inventory_file
end
