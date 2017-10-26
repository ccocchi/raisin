module Raisin
  class VersionConstraint
    def initialize(version)
      @version  = version
    end

    def matches?(req)
      @version == req.get_header('raisin.version'.freeze)
    end
  end
end
