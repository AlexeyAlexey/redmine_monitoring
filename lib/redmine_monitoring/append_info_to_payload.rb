module RedmineMonitoring
  module AppendInfoToPayload
    class ActionController::Base
      def append_info_to_payload(payload)
        super
        payload[:ip]         = request.remote_ip
        payload[:user_id]    = User.current.try(:id)
        payload[:session_id] = request.headers["rack.session"]["session_id"] || ""
        #headers
        payload[:headers] ||= {}
        payload[:headers]["HTTP_USER_AGENT"]   = request.headers["HTTP_USER_AGENT"]
        payload[:headers]["GATEWAY_INTERFACE"] = request.headers["GATEWAY_INTERFACE"]
        payload[:headers]["PATH_INFO"]         = request.headers["PATH_INFO"]
        payload[:headers]["QUERY_STRING"]      = request.headers["QUERY_STRING"]
        payload[:headers]["REMOTE_ADDR"]       = request.headers["REMOTE_ADDR"]
        payload[:headers]["REQUEST_METHOD"]    = request.headers["REQUEST_METHOD"]
        payload[:headers]["REQUEST_URI"]       = request.headers["REQUEST_URI"]
        payload[:headers]["SCRIPT_NAME"]       = request.headers["SCRIPT_NAME"]
        payload[:headers]["SERVER_NAME"]       = request.headers["SERVER_NAME"]
        payload[:headers]["SERVER_PORT"]       = request.headers["SERVER_PORT"]
        payload[:headers]["SERVER_PROTOCOL"]   = request.headers["SERVER_PROTOCOL"]
        payload[:headers]["SERVER_SOFTWARE"]   = request.headers["SERVER_SOFTWARE"]
        payload[:headers]["HTTP_HOST"]         = request.headers["HTTP_HOST"]
        payload[:headers]["HTTP_CONNECTION"]   = request.headers["HTTP_CONNECTION"]
        payload[:headers]["HTTP_CACHE_CONTROL"] = request.headers["HTTP_CACHE_CONTROL"]
        payload[:headers]["HTTP_UPGRADE_INSECURE_REQUESTS"] = request.headers["HTTP_UPGRADE_INSECURE_REQUESTS"]
        payload[:headers]["HTTP_ACCEPT"]                    = request.headers["HTTP_ACCEPT"]
        payload[:headers]["HTTP_ACCEPT_ENCODING"]           = request.headers["HTTP_ACCEPT_ENCODING"]
        payload[:headers]["HTTP_ACCEPT_LANGUAGE"]           = request.headers["HTTP_ACCEPT_LANGUAGE"]
        payload[:headers]["HTTP_VERSION"]                   = request.headers["HTTP_VERSION"]
        payload[:headers]["REQUEST_PATH"]                   = request.headers["REQUEST_PATH"]
        payload[:headers]["ORIGINAL_FULLPATH"]              = request.headers["ORIGINAL_FULLPATH"]
        payload[:headers]["HTTP_REFERER"]                   = request.headers["HTTP_REFERER"] || ""
      end
    end
  end
end