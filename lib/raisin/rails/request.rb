module Raisin
  module ApiFormat
    def formats
      @env["action_dispatch.request.formats"] ||= 
        if @env.key?('raisin.format')
          Array(Mime::Type.lookup(@env['raisin.format']))
        elsif parameters[:format]
          Array(Mime[parameters[:format]])
        elsif use_accept_header && valid_accept_header
          accepts
        elsif xhr?
          [Mime::JS]
        else
          [Mime::HTML]
        end
    end
  end
end

ActionDispatch::Request.send(:include, Raisin::ApiFormat)