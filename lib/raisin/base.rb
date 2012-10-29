require 'rack/mount'

module Raisin
  class Base < ActionController::Metal
    abstract!

    MODULES = [
      # ActionController::HideActions,
      ActionController::Rendering,
      # ActionController::Renderers::All
      ActionController::ImplicitRender,

      ActionController::ConditionalGet,
      ActionController::MimeResponds,

      ActionController::RackDelegation,
      ActionController::Instrumentation
    ]

    MODULES.each { |mod|
      include mod
    }

    def self.reset
      @_routes = []
    end

    def self.inherited(subclass)
      subclass.reset
      subclass.append_view_path "#{Rails.root}/app/views"
      super
    end

    # def self.route_into(route_set)
    #   @_routes.each do |method, path, action|
    #     route_set.add_route(self, {
    #       request_method: method,
    #       path_info: path
    #     }, { action: action })
    #   end
    # end

    class << self
      attr_internal_reader :routes

      def get(path, options = nil, &block)
        path = normalize_path(path)
        method_name = extract_method_name(path)

        define_method(method_name, &block)

        routes << [:get, path, default_route(method_name)]
        routes << [:get, '/index', default_route('index')] if path == '/'
      end
      alias_method :head, :get

      def post(path, options = nil, &block)
        path = normalize_path(path)
        method_name = extract_method_name(path)

        define_method(method_name, &block)

        routes << [:post, path, default_route(method_name)]
      end

      def put(path, options = nil, &block)
        path = normalize_path(path)
        method_name = extract_method_name(path)

        define_method(method_name, &block)

        routes << [:put, path, default_route(method_name)]
      end
      alias_method :patch, :put

      def delete(path, options = nil, &block)
        path = normalize_path(path)
        method_name = extract_method_name(path)

        define_method(method_name, &block)

        routes << [:delete, path, default_route(method_name)]
      end

      def default_route(method)
        "#{self.controller_name}##{method}"
      end

      #
      # Get method name from path
      # Example:
      #   / => 'index'
      #   /users/:id => 'users'
      #   /users/:id/addresses => 'addresses'
      #
      def extract_method_name(path)
        return 'index' if path == '/'
        path.split('/').reverse!.find { |part| !part.start_with?(':') }
      end

      #
      # Creates path with version, namespace and
      # given path, then normalizes it
      #
      def normalize_path(path)
        parts = []
        parts << path.to_s
        Rack::Mount::Utils.normalize_path(parts.join('/'))
      end
    end
  end
end