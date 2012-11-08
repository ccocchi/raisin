module Raisin
  module ApiFormat
    def formats
      @env["action_dispatch.request.formats"] ||= @env['raisin.request.formats'] || super
    end
  end
end

ActionDispatch::Request.send(:include, Raisin::ApiFormat)