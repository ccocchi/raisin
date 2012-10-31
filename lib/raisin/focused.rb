module Raisin
  module Focused
    extend ActiveSupport::Concern

    included do
      reset
    end

    module ClassMethods
      def api_name
        @api_name ||= self.name.demodulize.sub(/api/i, '').underscore
      end

      def reset
        @_routes = []
        @_prefix = self.api_name
        @_current_namespace = nil
      end

      %w(get head post put delete).each do |via|
        class_eval <<-EOF, __FILE__, __LINE__ + 1
          def #{via}(path, options = nil, &block)
            path = normalize_path(path)
            method_name = extract_method_name(path, :#{via})

            endpoint = Endpoint.new
            endpoint.instance_eval(&block)

            self.const_set method_name.capitalize.to_sym, Class.new(ActionController::Base) {
              define_method(:call, &(endpoint.response_body))
            }

            current_namespace.add(method_name) if current_namespace?

            routes << [:#{via}, path, default_route(method_name)]
          end
        EOF
      end

      def routes
        @_routes
      end

      def current_namespace
        @_current_namespace
      end
      alias_method :current_namespace?, :current_namespace

      def prefix(prefix)
        @_prefix = prefix
      end

      def prefix?
        @_prefix
      end

      def description(desc)
        # noop
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
            return unless current_namespace?
            current_namespace.filter(:#{type}, args, &block)
          end
        EOF
      end

      protected

      def process_filters
        current_namespace.filters.each_pair { |type, filters|
          filters.each do |name, block|
            superclass.send("#{type}_filter", name, only: current_namespace.methods, &block)
          end
        }
      end

      def default_route(method)
        "#{modules_prefix}users##{method}"
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
        parts << current_namespace.path unless !current_namespace? || path =~ %r(/#{current_namespace.path})
        parts << path.to_s unless path == '/'
        parts.join('/')
      end

    end
  end
end