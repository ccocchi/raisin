module Raisin
  class Railtie < Rails::Railtie

    initializer 'raisin.middleware' do |app|
      app.middleware.use Raisin::Middleware
    end

    initializer 'raisin.patch_rails' do
      ActionDispatch::Routing::Mapper.include(Raisin::Mapper)
    end
  end
end
