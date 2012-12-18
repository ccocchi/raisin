module Raisin
  module ApiFormat
    def formats
      @env["action_dispatch.request.formats"] ||= [Mime::Type.lookup('application/json')]
    end
  end
end

ActionDispatch::Request.send(:include, Raisin::ApiFormat)