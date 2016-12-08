class MonitoringResultsController < ApplicationController
  unloadable
  helper MonitoringResultsHelper
  before_filter :require_login
  #before_filter :find_project_by_project_id
  before_filter :find_project
  before_filter :authorize


  def index
  	@filter_form = params["filter"] || {}

    if Redmine::VERSION::MAJOR >= 3
      @monitoring_days = @project.monitoring_results.order("monitoring_day").pluck("monitoring_day", "id")
  	  #@monitoring_days = MonitoringResult.order("monitoring_day").pluck("monitoring_day", "id")
    else
      @monitoring_days = @project.monitoring_results.select("monitoring_day, id").order("monitoring_day").map{|mon| [mon.monitoring_day, mon.id]}
      #@monitoring_days = MonitoringResult.select("monitoring_day", "id").order("monitoring_day").map{|mon| [mon.monitoring_day, mon.id]}
    end
    @monitoring = @project.monitoring_results.where(nil)
  	#@monitoring = MonitoringResult.where(nil)

    @monitoring = @monitoring.where("id = ?", @filter_form["monitoring_day_id"])

  	#if @filter_form["monitoring_day"]
      #@monitoring = @monitoring.where("monitoring_day = DATE(?)", @filter_form["monitoring_day"])
  	#end

    @monitoring = @monitoring.first

    @all_controllers  = []
    @controllers_list = []

  	unless @monitoring.nil?
  	  @all_controllers = @monitoring.result.keys
      @all_controllers.delete_if{|el| ["controllers", "severity"].include?(el)}
  	end
    if !@filter_form["controllers"].blank? and !@filter_form["controllers"].first.blank? and @filter_form["generated_monitoring_day_id"] == @filter_form["monitoring_day_id"]
      @controllers_list = @filter_form["controllers"]
    end
    
  end
end
