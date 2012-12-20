module Raisin
  class Middleware
    ACCEPT_REGEXP = /application\/vnd\.(?<vendor>[a-z]+)-(?<version>v[0-9]+)\+(?<format>[a-z]+)?/

    def initialize(app)
      @app = app
      @vendor = Configuration.version.vendor
    end

    def call(env)
      @env = env
      if verify_accept_header
        @app.call(@env)
      else
        [406, {}, []]
      end
    end

    private

    def verify_accept_header
      if (matches = ACCEPT_REGEXP.match(@env['HTTP_ACCEPT'])) && @vendor == matches[:vendor]
        @env['raisin.version']  = matches[:version]
        @env['raisin.format']   = "application/#{matches[:format]}"
        true
      else
        false
      end
    end
  end
end