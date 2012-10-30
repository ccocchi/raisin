module Raisin
  module Middleware
    class Base
      def initialize(app, *args)
        @app = app
      end

      def call(env)
        @app.call(env)
      end
    end
  end
end