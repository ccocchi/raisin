require 'raisin/version'
require 'raisin/configuration'

require 'raisin/base'
require 'raisin/middleware'

module Raisin
  def self.configure
    yield Configuration if block_given?
  end
end

require 'raisin/railtie'