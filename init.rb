ActionDispatch::Callbacks.to_prepare do
  require_dependency 'redmine_monitoring_active_support_notifications/process_action_action_controller'

  Project.send(:include, RedmineMonitoring::ProjectPatch)
end
RedmineMonitoring::AppendInfoToPayload

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
  author 'Alexey Kondratenko'
  description 'This is a plugin for Redmine'
  version '0.1.0.beta'
  url 'https://github.com/AlexeyAlexey/redmine_monitoring'
  author_url 'https://github.com/AlexeyAlexey'


  project_module :redmine_monitoring do
    permission :monitoring_results, { :monitoring_results => [:index]}
  end

  menu :project_menu, :monitoring_results, { :controller => 'monitoring_results', :action => 'index' }, :caption => 'Redmine Monitoring Results'

  settings :default => {'empty' => true}, :partial => 'settings/redmine_monitoring/settings'
end
