module Raisin
  class VersionConstraint
    ACCEPT_REGEXP = /application\/vnd\.(?<vendor>[a-z]+)-(?<version>v[0-9]+)\+(?<format>[a-z]+)?/

    def initialize(version)
      @version  = version
      @bypass   = version == Router::ALL_VERSIONS
      @vendor   = Configuration.version.vendor
    end

    def matches?(req)
      (matches = ACCEPT_REGEXP.match(req.env['HTTP_ACCEPT'])) &&
      (@bypass || @version == matches[:version] && @vendor == matches[:vendor])
    end
  end
end