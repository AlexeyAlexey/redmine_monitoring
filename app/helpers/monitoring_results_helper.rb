module MonitoringResultsHelper

  def chart_controllers_number_of_requests_in_hour(monitoring, controllers_list)
    controllers_list.each do |controller_name|
      number_of_requests_in_hour = monitoring.result[controller_name]["controller"]["number_of_requests_in_hour"]
	    first_el = number_of_requests_in_hour.shift
	  
	    number_of_requests_in_hour = ["Number of Requests in hour #{controller_name}", ] + number_of_requests_in_hour.push(first_el)
	  
      yield number_of_requests_in_hour

    end
  end

  def chart_runtime_controllers(monitoring, controllers_list)
    monitoring_result = monitoring.result
    #view_runtime_max
    #db_runtime_max
    #duration_max
    duration_max     = ['duration_max']
    view_runtime_max = ['view_runtime_max']
    db_runtime_max   = ['db_runtime_max']

    controllers_list.each do |controller_name|
      duration_max     << monitoring_result[controller_name]["controller"]["duration_max"]
      view_runtime_max << monitoring_result[controller_name]["controller"]["view_runtime_max"]
      db_runtime_max   << monitoring_result[controller_name]["controller"]["db_runtime_max"]
    end
    yield [duration_max, view_runtime_max, db_runtime_max]
  end
end
