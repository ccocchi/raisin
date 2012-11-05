module Raisin
  class Endpoint
    include Exposable

    attr_reader :response_body, :auth_method, :formats

    def initialize
      @response_body  = nil
      @auth_method    = nil
      @formats = []
    end

    def response(&block)
      @response_body = block
    end

    def desc(description)
      # noop
    end

    def format(*mime_types)
      @formats.concat mime_types
    end

    def enable_auth(method = Configuration.default_auth_method)
      return if Configuration.enable_auth_by_default
      @auth_method = method
    end

    def skip_auth(method = Configuration.default_auth_method)
      return unless Configuration.enable_auth_by_default
      @auth_method = method
    end
  end
end