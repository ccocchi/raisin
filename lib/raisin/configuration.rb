module Raisin
  class VersionConfig
    attr_accessor :vendor
    attr_writer :using

    def using
      @using || :header
    end
  end

  module Configuration
    def self.version
      @version_config ||= VersionConfig.new
    end
  end
end