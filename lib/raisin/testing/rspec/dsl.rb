require 'raisin/testing/rspec/unit_helper'
require 'raisin/testing/rspec/api_helper'

module Raisin
  module Testing
    module RSpec

      #
      #
      #
      module HttpMethods
        %w(get head post put delete).each do |verb|
          class_eval <<-EOF, __FILE__, __LINE__ + 1
            def #{verb}(*args)
              method = self.example.metadata[:current_method].to_s.downcase
              super(method, *args)
            end
          EOF
        end
      end

      #
      #
      #
      module DSL
        %w(get head post put delete).each do |verb|
          class_eval <<-EOF, __FILE__, __LINE__ + 1
            def #{verb}(path_or_klass, &block)
              self.metadata[:current_klass] = _klass_from_path(path_or_klass, :#{verb})
              self.instance_eval(&block)
              self.metadata.delete(:current_klass)
            end
          EOF
        end

        def unit(&block)
          _describe_controller(self.metadata[:current_klass], self, &block).tap do |klass|
            klass.send(:include, Raisin::RSpecUnitHelper)
          end
        end

        def response(format = :json, &block)
          self.metadata[:type] = :api
          _describe_controller(self.metadata[:current_klass], self, &block).tap do |klass|
            klass.send(:include, Raisin::RSpecApiHelper)
            klass.send(:include, HttpMethods)
            klass.send(:render_views) if ::Raisin::Configuration.testing_render_views
            klass.send(:before) {
              request.accept = format.is_a?(Symbol) ? "application/#{format}" : format
            }
          self.metadata.delete(:type)
          end
        end

        protected

        def _klass_from_path(path_or_klass, via)
          api_klass = _find_first_api_klass

          case path_or_klass
          when String
            method_name = api_klass.send(:extract_method_name, api_klass.send(:normalize_path, path_or_klass), via)
            self.metadata[:current_method] = method_name
            api_klass.const_get(method_name.camelize)
          when Symbol
            self.metadata[:current_method] = path_or_klass
            api_klass.const_get(path_or_klass.to_s.camelize)
          else
            path_or_klass
          end
        end

        def _find_first_api_klass
          metadata = self.metadata[:example_group]
          klass = nil

          until metadata.nil? || klass.respond_to?(:new)
            klass    = metadata[:description_args].first
            metadata = metadata[:example_group]
          end

          klass
        end

        def _describe_controller(klass, parent, &block)
          result = parent.describe(klass, &block)
          result.instance_eval <<-EOF
            def controller_class
              #{klass}
            end
          EOF
          result
        end
      end
    end
  end
end