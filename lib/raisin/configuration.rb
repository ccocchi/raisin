module Raisin
  class VersionConfig
    attr_accessor :vendor
    attr_writer :using

    def using
      @using || :header
    end
  end

  module Configuration
    mattr_accessor :base_endpoint
    @@base_endpoint = 'ApiEndpoint'

    def self.version
      @version_config ||= VersionConfig.new
    end
  end
end