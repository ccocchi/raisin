module Raisin
  module Routing
    ALL_VERSIONS = 'all'

    class VersionConstraint
      def initialize(version, is_default)
        @version  = version
        @bypass   = is_default || version == ALL_VERSIONS
      end

      def matches?(req)
        @bypass || @version == req.env['raisin.version']
      end
    end
  end
end