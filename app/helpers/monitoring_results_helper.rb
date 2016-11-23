module MonitoringResultsHelper

  def chart_controllers_number_of_requests_in_hour(monitoring, controllers_list)
    controllers_list.each do |controller_name|
      number_of_requests_in_hour = monitoring.result[controller_name]["controller"]["number_of_requests_in_hour"]
	  first_el = number_of_requests_in_hour.shift
	  
	  number_of_requests_in_hour = ["Number of Requests in hour #{controller_name}", ] + number_of_requests_in_hour.push(first_el)
	  
      yield number_of_requests_in_hour

    end
  end
end
