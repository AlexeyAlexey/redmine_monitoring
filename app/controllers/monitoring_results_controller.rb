class MonitoringResultsController < ApplicationController
  unloadable
  helper MonitoringResultsHelper
  before_filter :require_login
  #before_filter :find_project_by_project_id
  before_filter :find_project
  before_filter :authorize


  def index

  	@monitoring = MonitoringResult.first
 
  	
    @pie_chart_controllers = @monitoring.result.keys
    @pie_chart_controllers.delete_if{|el| ["controllers", "severity"].include?(el)}
    @controllers_list = []
  end
end
