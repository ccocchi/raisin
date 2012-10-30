module Raisin
  class Namespace
    attr_reader :path, :methods, :filters

    def initialize(path)
      @path = path
      @methods = []
      @filters = {
        before: [],
        after:  [],
        around: []
      }
    end

    def add(method)
      @methods << method
    end

    def filter(type, *args, &block)
      @filters[type] << [args.first, block]
    end
  end
end