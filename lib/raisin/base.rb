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

      ActionController::Instrumentation
    ]

    MODULES.each { |mod|
      include mod
    }

    def self.controller_path
      @controller_path ||= name && name.sub(/\:\:[^\:]+$/, '').sub(/api$/i, '').underscore
    end

    def _prefixes
      @_prefixes ||= begin
        parent_prefixes = self.class.parent_prefixes
        parent_prefixes.compact.unshift(controller_path)#.map! { |pr| pr.split('/').last }
      end
    end

    def action_name
      self.class.name.demodulize.underscore
    end

    #
    # In test env, action is not :call. This is a bit of a hack
    #
    def process(action, *args)
      super(:call, *args)
    end

    ActiveSupport.run_load_hooks(:action_controller, self)
  end
end