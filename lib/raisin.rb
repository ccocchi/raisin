require 'raisin/version'
require 'raisin/mapper'
require 'raisin/middleware'

require 'raisin/railtie' if defined?(Rails)

module Raisin
  def self.configure
    yield self
  end

  def self.vendor
    @vendor || raise('`vendor` is not configured')
  end

  def self.vendor=(value)
    @vendor = value
  end
end
