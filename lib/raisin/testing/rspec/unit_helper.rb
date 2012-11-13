module Raisin
  module UnitHelper
    extend ActiveSupport::Concern

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

    def controller
      self.class.controller_class.new.tap do |c|
        c.request   = request
        c.response  = response
      end
    end

    def request
      @request ||= ActionDispatch::TestRequest.new
    end

    def response
      @response ||= ActionDispatch::TestResponse.new
    end
  end
end