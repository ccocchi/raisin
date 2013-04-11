module Raisin
  class Namespace
    attr_reader :path, :methods, :filters, :exposures

    def initialize(path)
      @path       = path
      @methods    = []
      @exposures  = []
      @filters    = {
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

    def expose(name, &block)
      @exposures << [name, block]
    end

    def expose?
      !exposures.empty?
    end
  end
end