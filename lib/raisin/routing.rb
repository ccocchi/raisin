module Raisin
  module Routing
    ALL_VERSIONS = 'all'

    class Mounter
      attr_reader :routes

      def initialize(version)
        @version  = version
        @routes   = []
      end

      def add(api)
        @routes.concat(api.routes)
      end

      protected

      def pathed_routes(routes)
        routes.map { |via, path, opts|
          path.append('/') unless path.start_with?('/')
          path.append(@version)
          [via, path, opts]
        }
      end
    end

    class VersionConstraint
      def initialize(version)
        @version  = version
        @bypass   = version == ALL_VERSIONS
      end

      def matches?(req)
        @bypass || @version == req.env['raisin.version']
      end
    end
  end
end