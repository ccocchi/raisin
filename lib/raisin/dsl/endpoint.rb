module Raisin
  module DSL
    module Endpoint
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
          respond_to *args
        end

        def enable_auth
          send(:before_filter, :authenticate_user!)
        end

        def disable_auth
          send(:skip_before_filter, :authenticate_user!)
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
end