module Raisin
  module Mixin
    extend ActiveSupport::Concern

    def call
    end

    module ClassMethods
      def response(&block)
        define_method(:call, &block) if block_given?
      end

      def desc(description)
        # noop
      end
      alias_method :description, :desc

      def format(*args)
        self.class_eval <<-EOF, __FILE__, __LINE__ + 1
          respond_to(*#{args})
        EOF
      end

      def enable_auth(method = nil)
        method ||= Configuration.default_auth_method
        send(:before_filter, method) unless Configuration.enable_auth_by_default
      end

      def disable_auth(method = nil)
        method ||= Configuration.default_auth_method
        send(:skip_before_filter, method) if Configuration.enable_auth_by_default
      end

      def expose(name, &block)
        if block_given?
          define_method(name) do |*args|
            ivar = "@#{name}"

            if instance_variable_defined?(ivar)
              instance_variable_get(ivar)
            else
              instance_variable_set(ivar, instance_exec(block, *args, &block))
            end
          end
        else
          attr_reader name
        end

        helper_method name
      end
    end
  end
end