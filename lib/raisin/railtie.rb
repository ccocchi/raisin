require 'raisin/rails/routes'
require 'raisin/rails/request'

module Raisin
  class Railtie < Rails::Railtie

    # Force routes to be loaded if we are doing any eager load.
    config.before_eager_load { |app| app.reload_routes! }
  end
end