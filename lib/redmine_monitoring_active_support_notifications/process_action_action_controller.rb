ActiveSupport::Notifications.subscribe "process_action.action_controller" do |*args|
  event = ActiveSupport::Notifications::Event.new *args
  event.duration
  Rails.logger.info event.to_json
end
