require 'raisin/testing/rspec/test_request'

module Raisin
  module FunctionalTest
    def self.append_features(base)
      base.class_eval do
        include RSpec::Rails::ControllerExampleGroup
        extend ClassMethods
      end

      super
    end

    module ClassMethods
      def controller_class
        metadata = self.metadata[:example_group]
        klass    = nil

        until metadata.nil? || klass.respond_to?(:new)
          klass    = metadata[:description_args].first
          metadata = metadata[:example_group]
        end

        klass.respond_to?(:new) ? klass : super
      end
    end
  end
end