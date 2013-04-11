module Raisin
  #
  # Middleware responsable to filter HTTP Accept header
  # It stores version and format accepted by the client in the env.
  #
  class Middleware
    ACCEPT_REGEXP = /application\/vnd\.(?<vendor>[a-z]+)-(?<version>v[0-9]+)\+(?<format>[a-z]+)?/

    def initialize(app)
      @app = app
      @vendor = Configuration.version.vendor
    end

    def call(env)
      @env = env
      verify_accept_header
      @app.call(@env)
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