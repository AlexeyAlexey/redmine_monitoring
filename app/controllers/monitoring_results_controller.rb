class MonitoringResultsController < ApplicationController
  unloadable
  helper MonitoringResultsHelper
  before_filter :require_login
  #before_filter :find_project_by_project_id
  before_filter :find_project
  before_filter :authorize


  def index
  	@filter_form = params["filter"] || {}

  	@monitoring_days = MonitoringResult.pluck("monitoring_day")

  	@monitoring = MonitoringResult.where(nil)

  	if @filter_form["monitoring_day"]
      @monitoring = MonitoringResult.where("monitoring_day = ?", @filter_form["monitoring_day"])
  	end

    @monitoring = @monitoring.first

    @all_controllers  = []
    @controllers_list = []

  	unless @monitoring.nil?
  	  @all_controllers = @monitoring.result.keys
      @all_controllers.delete_if{|el| ["controllers", "severity"].include?(el)}
  	end
    if !@filter_form["controllers"].blank? and !@filter_form["controllers"].first.blank?
      @controllers_list = @filter_form["controllers"]
    end
    
  end
end
