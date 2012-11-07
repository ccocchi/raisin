module Raisin
  module Configuration
    mattr_accessor :enable_auth_by_default
    @@enable_auth_by_default = false

    mattr_accessor :default_auth_method
    @@default_auth_method = :authenticate_user! # Devise FTW

    mattr_accessor :response_formats
    @@response_formats = [:json]
  end
end