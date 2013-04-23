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
    ]

    MODULES.each { |mod|
      include mod
    }

    ActiveSupport.run_load_hooks(:action_controller, self)
  end
end