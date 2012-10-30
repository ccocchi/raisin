module Raisin
  class API
    class Version
      attr_reader :version, :type, :options

      def initialize(version, options = {})
        @version = version.to_s
        @type = options.delete(:using).try(:to_sym) || :header
        @options = options

        # validate!
      end

      private

      def validate!
        case type
        when :header
          raise 'Missing :vendor options when using header versionning' unless options.key?(:vendor)
        end
      end
    end

    def self.reset
      @_current_version = nil
      @_routes = []
    end

    #
    # Reset class variables on the subclass when inherited
    #
    def self.inherited(subclass)
      subclass.reset
    end

    class << self
      attr_internal_accessor :routes, :current_version

      def mount(api)
        mount_version_middleware(api) if version?(:header)
        self.routes.concat(version?(:path) ? pathed_routes(api.routes) : api.routes)
      end

      #
      # Set version for current block
      #
      def version(version, options = {}, &block)
        self.current_version = Version.new(version, options)
        yield
        self.current_version = nil
      end

      private

      def mount_version_middleware(api)
        api.use_or_update Middleware::Header, self.current_version.version, self.current_version.options
      end

      def version?(type)
        self.current_version && self.current_version.type == type
      end

      def pathed_routes(routes)
        self.routes.map! { |via, path, opts|
          path.append('/') unless path.start_with?('/')
          path.append(current_version.version)
          [via, path, opts]
        }
      end
    end

    # #
    # # Make the API a rack endpoint
    # #
    # def self.call(env)
    #   @_route_set.freeze unless @_route_set.frozen?
    #   @_route_set.call(env)
    # end

    # Mount Raisin::Base into the api
    #

  end
end