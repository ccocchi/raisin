module Raisin
  #
  # Middleware responsable to filter HTTP Accept header
  # It stores version and format accepted by the client in the env.
  #
  class Middleware
    ACCEPT_REGEXP = /\Aapplication\/vnd\.(?<vendor>[a-z]+).(?<version>v[0-9]+)\+(?<format>[a-z]+)\Z/

    def initialize(app)
      @app    = app
      @vendor = Raisin.vendor
    end

    def call(env)
      extract_version_from_accept_header(ActionDispatch::Request.new(env))
      @app.call(env)
    end

    private

    def extract_version_from_accept_header(req)
      header = req.get_header('HTTP_ACCEPT'.freeze).to_s.strip

      if (matches = ACCEPT_REGEXP.match(header)) && @vendor == matches[:vendor]
        req.set_header('raisin.version'.freeze, matches[:version])
        req.format = matches[:format]
      end
    end
  end
end
