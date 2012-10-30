module Raisin
  class API
    class << self
      attr_internal_accessor :routes

      def reset
        @settings = {}
        @_routes = []
        # reset_routes
      end

      # def reset_routes
      #   @_route_set = Rack::Mount::RouteSet.new(
      #     request_class: ActionDispatch::Request,
      #     parameters_key: 'action_dispatch.request.path_parameters'
      #   )
      # end
    end

    # #
    # # Make the API a rack endpoint
    # #
    # def self.call(env)
    #   @_route_set.freeze unless @_route_set.frozen?
    #   @_route_set.call(env)
    # end

    #
    # Mount Raisin::Base into the api
    #
    def self.mount(api)
      # api.route_into(route_set)
      api.use_or_modify Middleware::Header, @settings[:version].to_s if @settings[:version]
      self.routes.concat api.routes
    end

    #
    # Reset class variables on the subclass when inherited
    #
    def self.inherited(subclass)
      subclass.reset
    end

    #
    # Set version for current block
    #
    def self.version(version, &block)
      @settings[:version] = version
      yield
      @settings[:version] = nil
    end
  end
end