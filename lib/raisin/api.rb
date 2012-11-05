module Raisin
  class MiddlewareStack < ActionDispatch::MiddlewareStack
    class Middleware < ActionDispatch::MiddlewareStack::Middleware
      def update(args)
        @args = args
      end
    end

    def build(action, app=nil, &block)
      super(app, &block)
    end
  end

  class API
    class_attribute :middleware_stack
    self.middleware_stack = Raisin::MiddlewareStack.new

    def self.action(name, klass = ActionDispatch::Request)
      middleware_stack.build(name) do |env|
        self.const_get(name.capitalize).new.dispatch(:call, klass.new(env))
      end
    end

    def self.use(*args, &block)
      middleware_stack.use(*args, &block)
    end

    def self.reset
      @_routes = []
      @_prefix = self.api_name
      @_current_namespace = nil
    end

    def self.inherited(subclass)
      subclass.reset
      subclass.middleware_stack = self.middleware_stack.dup
      super
    end

    def self.api_name
      @api_name ||= self.name.demodulize.sub(/api/i, '').underscore
    end

    def self.use_or_update(klass, *args)
      m = middleware_stack.find { |m| m == klass }
      if m
        m.update klass.merge(m.args, args)
      else
        self.use(klass, *args)
      end
    end

    def self.routes
      @_routes
    end

    module DSL
      %w(get head post put delete).each do |via|
        class_eval <<-EOF, __FILE__, __LINE__ + 1
          def #{via}(path, options = nil, &block)
            path = normalize_path(path)
            method_name = extract_method_name(path, :#{via})

            endpoint = Endpoint.new
            endpoint.instance_eval(&block)

            n = current_namespace

            self.const_set method_name.capitalize.to_sym, Class.new(::Raisin::Base) {
              respond_to :json

              define_method(:call, &(endpoint.response_body))

              _expose(n.exposure, &(n.lazy_expose)) if n.expose?
              _expose(endpoint.exposure, &(endpoint.lazy_expose)) if endpoint.expose?
            }

            current_namespace.add(method_name) if current_namespace

            routes << [:#{via}, path, default_route(method_name)]
          end
        EOF
      end

      def prefix(prefix)
        @_prefix = prefix
      end

      def description(desc)
        # noop
      end

      def expose(*args, &block)
        current_namespace.expose(*args, &block)
      end

      def namespace(path, &block)
        path = path.sub(%r(\A/?#{@_prefix}), '') if prefix?
        old_namespace, @_current_namespace = current_namespace, Namespace.new(path)
        yield
        process_filters
        @_current_namespace = old_namespace
      end

      %w(before around after).each do |type|
        class_eval <<-EOF, __FILE__, __LINE__ + 1
          def #{type}(*args, &block)
            return unless current_namespace
            current_namespace.filter(:#{type}, args, &block)
          end
        EOF
      end

      protected

      def prefix?
        @_prefix
      end

      def current_namespace
        @_current_namespace
      end
      alias_method :current_namespace?, :current_namespace

      def process_filters
        current_namespace.filters.each_pair { |type, filters|
          filters.each do |name, block|
            superclass.send("#{type}_filter", name, only: current_namespace.methods, &block)
          end
        }
      end

      def default_route(method)
        "#{modules_prefix}#{self.api_name}##{method}"
      end

      def modules_prefix
        @modules_prefix ||= begin
          modules = self.name.split('::').slice(0..-2)
          modules.empty? ? '' : "#{modules.join('/')}/"
        end
      end

      #
      # Get method name from path
      # Example:
      #   / => :index
      #   /users/:id => :users
      #   /users/:id/addresses => :addresses
      #
      def extract_method_name(path, via)
        return :index if path =~ %r(\A/?#{@_prefix}\z)

        parts = path.split('/').reverse!

        return parts.find { |part| !part.start_with?(':') } if parts.first != ':id'

        case via
        when :get
          :show
        when :post
          :create
        when :put
          :update
        when :delete
          :destroy
        else
          raise "Cannot extract method name from #{path}"
        end
      end

      #
      # Creates path with version, namespace and
      # given path, then normalizes it
      #
      def normalize_path(path)
        parts = []
        parts << @_prefix unless !prefix? || path =~ %r(\A/?#{@_prefix})
        parts << current_namespace.path unless !current_namespace || path =~ %r(/#{current_namespace.path})
        parts << path.to_s unless path == '/'
        parts.join('/')
      end
    end

    extend DSL

  end
end