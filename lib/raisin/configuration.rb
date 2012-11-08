module Raisin
  class VersionConfig
    attr_accessor :vendor
    attr_writer :using

    def using
      @using || :header
    end
  end

  module Configuration
    mattr_accessor :enable_auth_by_default
    @@enable_auth_by_default = false

    mattr_accessor :default_auth_method
    @@default_auth_method = :authenticate_user! # Devise FTW

    mattr_accessor :response_formats
    @@response_formats = [:json]

    def self.version
      @version_config ||= VersionConfig.new
    end
  end
end