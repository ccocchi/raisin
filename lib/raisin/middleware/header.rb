module Raisin
  module Middleware
    class Header < Base

      def self.merge(base, other)
        base_options, other_options = base.pop, other.pop
        [base.concat(other), base_options.merge!(other_options)]
      end

      attr_reader :options, :versions

      def initialize(app, versions, options = {})
        super
        @options = options
        @versions = Array(versions)
      end

      def call(env)
        @env = env
        return [406, {}, ["You shall not pass!"]] unless verify_http_accept_header
        super
      end

      private

      def verify_http_accept_header
        header = @env['HTTP_ACCEPT']
        if (matches = %r{application/vnd\.(?<vendor>[a-z]+)-(?<version>v[0-9]+)(?<format>\+[a-z]+)?}.match(header))
          versions.include?(matches[:version]) &&
           (!options.key?(:vendor) || options[:vendor] == matches[:vendor]) ? true : false
        else
          false
        end
      end
    end
  end
end