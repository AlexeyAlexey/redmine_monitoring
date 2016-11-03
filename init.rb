ActionDispatch::Callbacks.to_prepare do
  require_dependency 'redmine_monitoring_active_support_notifications/process_action_action_controller'
end

RedmineApp::Application.config.middleware.use(RedmineMonitoring::RedmineMonitoringMiddleware)

RedmineApp::Application.config.middleware.insert_before "ActionDispatch::Static", "RequestStore::Middleware"
RedmineApp::Application.config.middleware.insert_after "RequestStore::Middleware", "RedmineMonitoring::RedmineMonitoringMiddleware"

RedmineApp::Application.config.logstash = LogStashLogger.configure do |config|
  config.customize_event do |event|
    event["request_unique_id"] = RequestStore.store[:request_unique_id]
  end
end


Redmine::Plugin.register :redmine_monitoring do
  name 'Redmine Monitoring plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
end
