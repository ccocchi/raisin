require 'raisin/api/dsl'

module Raisin
  class API

    #
    # Returns a proc representing our action to be called in the given
    # environment.
    #
    def self.action(name, klass = ActionDispatch::Request)
      ->(env) { self.const_get(name.camelize).new.dispatch(:call, klass.new(env)) }
    end

    #
    # The abstract class that is inherited by all actions.
    #
    # It includes actions DSL, default call method, global authentication
    # filter and global respond_to
    #
    def self.action_klass
      @_klass ||= begin
        klass = Class.new(::Raisin::Base)
        klass.send(:include, Raisin::Mixin)

        if Configuration.enable_auth_by_default && Configuration.default_auth_method
          klass.send(:before_filter, Configuration.default_auth_method)
        end

        klass.send(:respond_to, *Configuration.response_formats)
        klass
      end
    end

    def self.action_klass=(klass) # :nodoc:
      @_klass = klass
    end

    #
    # Resets routes and namespaces.
    # Sets default prefix to api_name (e.g PostsAPI => 'api')
    #
    def self.reset
      @_routes = []
      @_prefix = self.api_name
      @_namespaces = []
      @_single_resource = false
    end

    #
    # Resets routes and namespaces for each new API class.
    # The action class is copied for some reasons (??)
    #
    def self.inherited(subclass)
      super
      subclass.reset
      subclass.action_klass = self.action_klass.dup
    end

    #
    # Returns the last part of the api's name, underscored, without the ending
    # <tt>API</tt>. For instance, PostsAPI returns <tt>posts</tt>.
    # Namespaces are left out, so Admin::PostsAPI returns <tt>posts</tt> as well.
    #
    def self.api_name
      @api_name ||= self.name.demodulize.sub(/api/i, '').underscore
    end

    def self.routes # :nodoc:
      @_routes
    end

    extend Raisin::DSL
  end
end