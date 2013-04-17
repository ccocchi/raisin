module Raisin
  module Vendor
    module NewRelic
      extend ActiveSupport::Concern

      included do
        include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation
      end

      def process_action(*args)
        perform_action_with_newrelic_trace(category: :controller, name: action_name, class_name: self.class.api_name) do
          super
        end
      end
    end
  end
end