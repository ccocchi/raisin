require 'raisin/version'

require 'raisin/configuration'

require 'raisin/exposable'
require 'raisin/namespace'
require 'raisin/mixin'

require 'raisin/router'
require 'raisin/base'
require 'raisin/api'

require 'raisin/middleware'
require 'raisin/version_constraint'

module Raisin
  def self.configure
    yield Configuration if block_given?
  end
end

require 'raisin/railtie'