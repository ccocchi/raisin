module Raisin
  class Endpoint
    include Exposable

    attr_reader :response_body

    def initialize
    end

    def response(&block)
      @response_body = block
    end

    def desc(description)
      # noop
    end
  end
end