module Raisin
  module RSpecApiHelper
    extend ActiveSupport::Concern

    included do
      include RSpec::Rails::ControllerExampleGroup
      subject { controller }
    end

  end
end

