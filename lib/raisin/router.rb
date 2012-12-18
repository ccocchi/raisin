module Raisin
  class Router
    ALL_VERSIONS = :all

    #
    # Reset class variables on the subclass when inherited
    #
    def self.inherited(subclass)
      subclass.reset
    end

    def self.reset
      @_current_version = nil
      @_versions = { ALL_VERSIONS => [] }
    end

    class << self
      attr_internal_accessor :versions, :current_version

      def mount(api)
        if version?(:header)
          @_versions[self.current_version].concat(api.routes)
        else
          @_versions[ALL_VERSIONS].concat(version?(:path) ? pathed_routes(api.routes) : api.routes)
        end
      end

      #
      # Set version for current block
      #
      def version(version, options = {}, &block)
        version = version.to_s
        self.current_version = version
        @_versions[version] = [] if version?(:header)
        yield
        self.current_version = nil
      end

      private

      def version?(type)
        self.current_version && Configuration.version.using == type
      end

      def pathed_routes(routes)
        self.routes.map! { |via, path, opts|
          path.append('/') unless path.start_with?('/')
          path.append(current_version.version)
          [via, path, opts]
        }
      end
    end

  end
end