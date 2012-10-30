module Raisin
  module Middleware
    class Header < Base

      def call(env)
        @env = env
        return [406, {}, ["You shall not pass!"]] unless verify_http_accept_header
        super
      end

      private

      def verify_http_accept_header
        header = @env['HTTP_ACCEPT']
        if (matches = %r{application/vnd\.(?<vendor>[a-z]+)-(?<version>v[0-9]+)\+json}.match(header))
          @args.include?(matches[:version]) ? true : false
        else
          false
        end
      end
    end
  end
end