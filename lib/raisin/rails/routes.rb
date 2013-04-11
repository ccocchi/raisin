require 'raisin/routing'

module ActionDispatch::Routing
  class Mapper
    def api_version(version)
      version = version.to_s
      mounter = Raisin::Routing::Mounter.new(version)

      yield mounter

      send(:constraints, Raisin::Routing::VersionConstraint.new(version)) do
        mounter.routes.each do |method, path, endpoint|
          send(method, path, to: endpoint)
        end
      end unless mounter.routes.empty?
    end
  end

  class RouteSet
    class Dispatcher

      #
      # Allow to use controller like 'UsersAPI' instead of 'UsersController'
      #
      def controller_reference_with_api(controller_param)
        controller_name = "#{controller_param.camelize}Api"
        unless controller = @controllers[controller_param]
          controller = @controllers[controller_param] =
            ActiveSupport::Dependencies.reference(controller_name)
        end
        controller.get(controller_name)
      rescue NameError
        controller_reference_without_api(controller_param)
      end

      alias_method_chain :controller_reference, :api
    end
  end
end