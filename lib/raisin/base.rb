require 'raisin/dsl/endpoint'

module Raisin

  #
  # Abstract class for all actions.
  #
  class Base < ActionController::Metal
    abstract!

    module Compatibility
      def cache_store; end
      def cache_store=(*); end
      def assets_dir=(*); end
      def javascripts_dir=(*); end
      def stylesheets_dir=(*); end
      def page_cache_directory=(*); end
      def asset_path=(*); end
      def asset_host=(*); end
      def relative_url_root=(*); end
      def perform_caching=(*); end
      def helpers_path=(*); end
      def allow_forgery_protection=(*); end
    end

    extend Compatibility

    MODULES = [
      AbstractController::Helpers,
      ActionController::UrlFor,
      ActionController::Rendering,
      ActionController::Renderers::All,

      ActionController::ConditionalGet,

      ActionController::RackDelegation,
      ActionController::MimeResponds,
      ActionController::ImplicitRender,
      ActionController::DataStreaming,

      AbstractController::Callbacks,
      ActionController::Rescue,

      ActionController::Instrumentation,
      DSL::Endpoint
    ]

    MODULES.each { |mod|
      include mod
    }

    class << self
      #
      # Name of the API which this action is part of
      #   V1::UsersAPI::Index => "V1::UsersAPI"
      #
      def api_name
        @api_name ||= (length = self.name.rindex('::')) ? self.name.slice(0, length) : self.name
      end

      #
      # Rails method for finding views adapted for APIs
      #   V1::UsersAPI::Index => "v1/users"
      #
      def controller_path
        @controller_path ||= api_name.sub(/api$/i, '').underscore
      end

      #
      # There's only one action method defined per class so no need
      # to dynamically found them
      #
      def action_methods
        @action_methods ||= ['call']
      end
    end

    def action_name # :nodoc:
      @action_name ||= self.class.name.demodulize.underscore
    end

    #
    # In test env, action is not :call, so we force the action to be
    # :call. In other env, action will already be :call so it's fine
    #
    def process(action, *args)
      super(:call, *args)
    end

    ActiveSupport.run_load_hooks(:action_controller, self)
  end
end