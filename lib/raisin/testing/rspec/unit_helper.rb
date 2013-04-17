module Raisin
  module TestFalseRendering
    attr_reader :_render_options

    #
    # Makes rendering options available and removes
    # `_render_template` call
    #
    def render_to_body(options = {})
      _process_options(options)
      @_render_options = options
    end

    #
    # Mimic ActionController::ImplicitRender when using
    # `call` method directly in a test to be able to use
    # @_render_options
    #
    def call
      super
      default_render unless @_render_options
    end
  end

  module UnitHelper
    extend ActiveSupport::Concern
    include ActionDispatch::Assertions::ResponseAssertions

    module ClassMethods
      def endpoint_class
        metadata = self.metadata[:example_group]
        klass    = nil

        until metadata.nil? || klass.respond_to?(:new)
          klass    = metadata[:description_args].first
          metadata = metadata[:example_group]
        end

        klass.respond_to?(:new) ? klass : super
      end
    end

    def endpoint
      @endpoint ||= begin
        endpoint = self.class.endpoint_class.new
        endpoint.singleton_class.send :include, TestFalseRendering
        endpoint.request  = request
        endpoint.response = response
        endpoint
      end
    end

    def request
      @request ||= begin
        request = ActionDispatch::TestRequest.new
        request.format = :json
        request
      end
    end

    def response
      @response ||= ActionDispatch::TestResponse.new
    end

    def assert_template(expected, message = nil)
      template_name = endpoint._render_options[:template]
      templates = endpoint._render_options[:prefixes].inject([]) { |res, prefix|
        res << "#{prefix}/#{template_name}"
      }
      templates.unshift(template_name)

      assert_include templates, expected.to_s, message
    end

    def assert_response(type, message = nil)
      endpoint # make sure endpoint is initialized
      super
    end

    def assert_redirected_to(location, message = nil)
      endpoint # make sure endpoint is initialized
      super
    end
  end
end