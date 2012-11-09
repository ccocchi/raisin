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
        self.const_get(name.camelize).new.dispatch(:call, klass.new(env))
      end
    end

    def self.use(*args, &block)
      middleware_stack.use(*args, &block)
    end

    def self.action_klass
      @_klass ||= begin
        klass = Class.new(::Raisin::Base)
        klass.send(:include, Raisin::Mixin)

        if Configuration.enable_auth_by_default && Configuration.default_auth_method
          klass.send(:before_filter, Configuration.default_auth_method)
        end

        klass.send(:respond_to, *Configuration.response_formats)
        klass
      end
    end

    def self.action_klass=(klass)
      @_klass = klass
    end

    def self.reset
      @_routes = []
      @_prefix = self.api_name
      @_namespaces = []
      @_single_resource = false
    end

    def self.inherited(subclass)
      subclass.reset
      subclass.middleware_stack = self.middleware_stack.dup
      subclass.action_klass = self.action_klass.dup
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
          def #{via}(path = '/', options = nil, &block)
            path = normalize_path(path)
            method_name = extract_method_name(path, :#{via})

            klass = self.const_set method_name.camelize.to_sym, Class.new(@_klass, &block)
            klass.send(:expose, current_namespace.exposure, &(current_namespace.lazy_expose)) if current_namespace.try(:expose?)

            current_namespace.add(method_name) if current_namespace

            routes << [:#{via}, path, default_route(method_name)]
          end
        EOF
      end

      def included(&block)
        self.action_klass.class_eval(&block) if block_given?
      end

      def member(&block)
        namespace(':id') do
          resource = self.api_name.singularize
          expose(resource) { resource.camelize.constantize.send :find, params[:id] }
          instance_eval(&block)
        end
      end

      def nested_into_resource(parent)
        parent = parent.to_s
        sing = parent.singularize
        id = "#{sing}_id"

        @_namespaces << Namespace.new("#{parent}/:#{id}")
        current_namespace.expose(sing) { sing.camelize.constantize.send :find, params[id.to_sym]}
        @_namespaces << Namespace.new(@_prefix)
        @_prefix = nil
      end

      def single_resource
        @_single_resource = true
        @_prefix = @_prefix.singularize if prefix?
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
        @_namespaces.push Namespace.new(path)
        yield
        process_filters
        @_namespaces.pop
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
        !!@_prefix
      end

      def single_resource?
        !!@_single_resource
      end

      def current_namespace
        @_namespaces.at(0)
      end

      def current_namespace?
        @_namespaces.length > 0
      end

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
          modules.empty? ? '' : "#{modules.map!(&:downcase).join('/')}/"
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
        return method_name_for_single_resource(path, via) if single_resource?

        if path =~ %r(\A/?#{@_prefix}\z)
          return via == :get ? 'index' : 'create'
        end

        parts = path.split('/').reverse!

        return parts.find { |part| !part.start_with?(':') } if parts.first != ':id'

        case via
        when :get
          'show'
        when :put
          'update'
        when :delete
          'destroy'
        else
          raise "Cannot extract method name from #{path}"
        end
      end

      def method_name_for_single_resource(path, via)
        if path =~ %r(\A/?#{@_prefix}\z)
          case via
          when :get
            'show'
          when :post
            'create'
          when :put
            'update'
          when :delete
            'destroy'
          end
        else
          path.split('/').reverse!.last
        end
      end

      #
      # Creates path with version, namespace and
      # given path, then normalizes it
      #
      def normalize_path(path)
        parts = []
        parts << @_prefix unless !prefix? || path =~ %r(\A/?#{@_prefix})
        parts.concat @_namespaces.reject { |n| path =~ %r(/#{n.path}) }.map!(&:path) if current_namespace?
        parts << path.to_s unless path == '/'
        parts.join('/')
      end
    end

    extend DSL

  end
end