require 'raisin/version'

require 'raisin/middleware/base'
require 'raisin/middleware/header'

require 'raisin/configuration'

require 'raisin/exposable'
require 'raisin/namespace'
require 'raisin/mixin'

require 'raisin/router'
require 'raisin/base'
require 'raisin/api'

module Raisin
  def self.configure
    yield Configuration if block_given?
  end
end

require 'raisin/railtie'