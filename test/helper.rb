ENV['RAILS_ENV'] = 'test'
$:.unshift File.expand_path('../../lib', __FILE__)

require 'minitest/mock'
require 'minitest/autorun'

require 'active_support/concern'
require 'action_dispatch'
require 'raisin'

Raisin.vendor = 'acme'
