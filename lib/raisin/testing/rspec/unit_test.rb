require 'raisin/testing/rspec/unit_helper'

module Raisin
  module UnitTest
    if defined?(RSpec::Rails)
      include RSpec::Rails::RailsExampleGroup
      include RSpec::Rails::Matchers::RedirectTo
      include RSpec::Rails::Matchers::RenderTemplate
    end

    def self.append_features(base)
      base.class_eval do
        include Raisin::UnitHelper
        subject { controller }
      end

      super
    end

  end
end