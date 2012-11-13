module ActionController
  class TestRequest < ActionDispatch::TestRequest

    #
    # Transforms Raisin controller's path as a standart Rails path
    # before assigning parameters to the request
    #
    # Example:
    #   controller_path: 'users_api#index', action: 'index'
    #   becomes
    #   controller_path: 'users', action: 'index'
    #
    def assign_parameters_with_api(routes, controller_path, action, parameters = {})
      controller_path.sub!(/_api/, '')
      controller_path.sub!(/\/?#{action}/, '')
      assign_parameters_without_api(routes, controller_path, action, parameters)
    end

    alias_method_chain :assign_parameters, :api
  end
end