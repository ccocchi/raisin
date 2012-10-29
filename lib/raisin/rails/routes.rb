module ActionDispatch::Routing
  class Mapper

    #
    #
    #
    def mount_api(raisin_api)
      raisin_api.routes.each do |method, path, endpoint|
        send(method, path, to: endpoint) # get '/users', to: 'users#index'
      end
    end
  end
end