module MonitoringResultsHelper

  def chart_controllers_number_of_requests_in_hour(monitoring, controllers_list)
    controllers_list.each do |controller_name|
      number_of_requests_in_hour = monitoring.result[controller_name]["controller"]["number_of_requests_in_hour"]
	    first_el = number_of_requests_in_hour.shift
	  
	    number_of_requests_in_hour = ["Number of Requests in hour #{controller_name}", ] + number_of_requests_in_hour.push(first_el)
	  
      yield number_of_requests_in_hour

    end
  end

  def chart_runtime_controllers(monitoring, controllers_list, runtime_types)
    monitoring_result = monitoring.result
    #view_runtime_max
    #db_runtime_max
    #duration_max
    runtime = {"view_runtime_max" => ["view_runtime_max"], "db_runtime_max" => ["db_runtime_max"], "duration_max" => ["duration_max"]}
    controllers_list.each do |controller_name|
      runtime_types.each do |runtime_type|
        runtime[runtime_type] << monitoring_result[controller_name]["controller"][runtime_type]
      end      
    end
    yield runtime.values_at(*runtime_types)
  end

  def chart_runtime_actions(monitoring, controller_name, runtime_types)
    monitoring_result = monitoring.result[controller_name]
    #view_runtime_max
    #db_runtime_max
    #duration_max
    runtime = {"view_runtime_max" => ["view_runtime_max"], "db_runtime_max" => ["db_runtime_max"], "duration_max" => ["duration_max"]}
    actions = monitoring_result.keys.delete_if{|act| act == "controller"}

    actions.each do |action|
      unless action == "controller"
        runtime_types.each do |runtime_type|
          runtime[runtime_type] << monitoring_result[action][runtime_type]
        end
      end
    end
    yield runtime.values_at(*runtime_types)
  end
end
