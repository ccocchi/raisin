module Raisin
  module UnitTest
    if defined?(RSpec::Rails)
      include RSpec::Rails::RailsExampleGroup
      include RSpec::Rails::Matchers::RedirectTo
      include RSpec::Rails::Matchers::RenderTemplate
    end

    %w(get post put delete).each do |method|
      define_method(method) do
        request.request_method = method
        subject.call
      end
    end

    def self.append_features(base)
      base.class_eval do
        include Raisin::UnitHelper
        subject { endpoint }
      end
      super
    end

  end
end