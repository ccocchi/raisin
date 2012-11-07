module Raisin
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
      # def helper_method(*); end
      # def helper(*); end
    end

    extend Compatibility

    MODULES = [
      AbstractController::Helpers,
      # ActionController::HideActions,
      ActionController::Rendering,
      # ActionController::Renderers::All
      ActionController::ImplicitRender,

      ActionController::ConditionalGet,
      ActionController::MimeResponds,

      ActionController::RackDelegation,

      AbstractController::Callbacks,

      ActionController::Instrumentation
    ]

    MODULES.each { |mod|
      include mod
    }

    def self._expose(name, &block)
      if block_given?
        define_method(name) do |*args|
          ivar = "@#{name}"

          if instance_variable_defined?(ivar)
            instance_variable_get(ivar)
          else
            instance_variable_set(ivar, instance_exec(block, *args, &block))
          end
        end
      else
        attr_reader name
      end

      helper_method name
    end

    def self.controller_path
      @controller_path ||= name && name.sub(/\:\:[^\:]+$/, '').sub(/api$/i, '').underscore
    end

    def action_name
      self.class.name.demodulize.underscore
    end

    #
    # Avoid action mising and fallback to default rendering
    #
    def call
    end

    # class << self
    #   attr_internal_reader :routes, :current_namespace

    #   alias :current_namespace? :current_namespace

    #   %w(get head post put delete).each do |via|
    #     class_eval <<-EOF, __FILE__, __LINE__ + 1
    #       def #{via}(path, options = nil, &block)
    #         path = normalize_path(path)
    #         method_name = extract_method_name(path, :#{via})

    #         endpoint = Endpoint.new
    #         endpoint.instance_eval(&block)

    #         Rails.logger.warn("WARNING: redefinition of method " << method_name) if method_defined?(method_name)
    #         define_method(method_name, &(endpoint.response_body))

    #         current_namespace.add(method_name) if current_namespace?

    #         routes << [:#{via}, path, default_route(method_name)]
    #       end
    #     EOF
    #   end

    #   def prefix(prefix)
    #     @_prefix = prefix
    #   end

    #   def prefix?
    #     @_prefix
    #   end

    #   def description(desc)
    #     # noop
    #   end

    #   # def get(path, options = nil, &block)
    #   #   path = normalize_path(path)
    #   #   method_name = extract_method_name(path, :get)

    #   #   endpoint = Endpoint.new
    #   #   endpoint.instance_eval(&block)

    #   #   define_method(method_name, &(endpoint.response_body))

    #   #   current_namespace.add(method_name) if current_namespace?

    #   #   routes << [:get, path, default_route(method_name)]
    #   # end
    #   # alias_method :head, :get

    #   # def post(path, options = nil, &block)
    #   #   path = normalize_path(path)
    #   #   method_name = extract_method_name(path)

    #   #   define_method(method_name, &block)

    #   #   routes << [:post, path, default_route(method_name)]
    #   # end

    #   # def put(path, options = nil, &block)
    #   #   path = normalize_path(path)
    #   #   method_name = extract_method_name(path)

    #   #   define_method(method_name, &block)

    #   #   routes << [:put, path, default_route(method_name)]
    #   # end
    #   # alias_method :patch, :put

    #   # def delete(path, options = nil, &block)
    #   #   path = normalize_path(path)
    #   #   method_name = extract_method_name(path)

    #   #   define_method(method_name, &block)

    #   #   routes << [:delete, path, default_route(method_name)]
    #   # end

    #   def namespace(path, &block)
    #     path = path.sub(%r(\A/?#{@_prefix}), '') if prefix?
    #     old_namespace, @_current_namespace = current_namespace, Namespace.new(path)
    #     yield
    #     process_filters
    #     @_current_namespace = old_namespace
    #   end

    #   %w(before around after).each do |type|
    #     class_eval <<-EOF, __FILE__, __LINE__ + 1
    #       def #{type}(*args, &block)
    #         return unless current_namespace?
    #         current_namespace.filter(:#{type}, args, &block)
    #       end
    #     EOF
    #   end

    #   protected

    #   def process_filters
    #     current_namespace.filters.each_pair { |type, filters|
    #       filters.each do |name, block|
    #         superclass.send("#{type}_filter", name, only: current_namespace.methods, &block)
    #       end
    #     }
    #   end

    #   def default_route(method)
    #     "#{modules_prefix}#{self.api_name}##{method}"
    #   end

    #   def modules_prefix
    #     @modules_prefix ||= begin
    #       modules = self.name.split('::').slice(0..-2)
    #       modules.empty? ? '' : "#{modules.join('/')}/"
    #     end
    #   end

    #   #
    #   # Get method name from path
    #   # Example:
    #   #   / => :index
    #   #   /users/:id => :users
    #   #   /users/:id/addresses => :addresses
    #   #
    #   def extract_method_name(path, via)
    #     return :index if path =~ %r(\A/?#{@_prefix}\z)

    #     parts = path.split('/').reverse!

    #     return parts.find { |part| !part.start_with?(':') } if parts.first != ':id'

    #     case via
    #     when :get
    #       :show
    #     when :post
    #       :create
    #     when :put
    #       :update
    #     when :delete
    #       :destroy
    #     else
    #       raise "Cannot extract method name from #{path}"
    #     end
    #   end

    #   #
    #   # Creates path with version, namespace and
    #   # given path, then normalizes it
    #   #
    #   def normalize_path(path)
    #     parts = []
    #     parts << @_prefix unless !@_prefix || path =~ %r(\A/?#{@_prefix})
    #     parts << current_namespace.path unless !current_namespace? || path =~ %r(/#{current_namespace.path})
    #     parts << path.to_s unless path == '/'
    #     parts.join('/')
    #   end
    # end

    ActiveSupport.run_load_hooks(:action_controller, self)
  end
end