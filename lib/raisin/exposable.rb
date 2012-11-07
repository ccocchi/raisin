module Raisin
  module Exposable
    extend ActiveSupport::Concern

    included do
      attr_reader :exposure, :lazy_expose
    end

    def expose(name, &block)
      @exposure = name
      @lazy_expose = block
    end

    def expose?
      !!@exposure
    end
  end
end