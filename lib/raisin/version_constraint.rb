module Raisin
  class VersionConstraint
    def initialize(version)
      @version  = version
      @bypass   = version == Router::ALL_VERSIONS
    end

    def matches?(req)
      @bypass || @version == req.env['raisin.version']
    end
  end
end