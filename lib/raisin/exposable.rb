module Raisin
  module Exposable
    extend ActiveSupport::Concern

    included do
      attr_reader :exposures
    end

    def initialize(*args)
      @exposures = []
    end

    def expose(name, &block)
      @exposures << [name, block]
    end

    def expose?
      !exposures.empty?
    end
  end
end