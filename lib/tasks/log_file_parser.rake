namespace :monitoring do
  desc 'Log parser'
  task :parse_log_file => :environment do
    day   = 4
    month = 11
    year  = 2016
  	
  	monitoring = {controller: {	number_of_requests_in_hour: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
							    number_of_requests: 0,
							    view_runtime_max: 0,
							    db_runtime_max: 0,
							    duration_max: 0,
							    controllers_list: []
							  },
				   severity: { number_of_error: 0,
					  	  	   number_of_fatal: 0,
							   number_of_unknown: 0,
							   number_of_warn: 0
							  }
		         }
    IO.foreach("./log/development.log") do |x| 
      line = {}
      begin
      	line = JSON.parse(x)
      rescue Exception => e
      	
      end
      
      unless line.empty?
        severity        = line["severity"]
        timestamp_str   = line["@timestamp"] || line["time"]
        timestamp       = Time.parse(timestamp_str)
        timestamp_hour  = Time.parse(timestamp_str).hour
        timestamp_day   = Time.parse(timestamp_str).day
        timestamp_month = Time.parse(timestamp_str).month
        timestamp_year  = Time.parse(timestamp_str).year
      end
      if line["name"] == "process_action.action_controller" and timestamp_day == day and timestamp_month == month and timestamp_year == year

      	controller = "#{line["payload"]["controller"]}"
      	controller_action = "#{line["payload"]["controller"]}:#{line["payload"]["action"]}"
		
		status       = line["payload"]["status"]# => 200
		view_runtime = line["payload"]["view_runtime"]#=> 2742.154952
		db_runtime   = line["payload"]["db_runtime"]#=> 51.33422399999999
		duration     = line["duration"]
		
      	monitoring[controller_action] ||= {  number_of_requests_in_hour: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
							                 number_of_requests: 0,
							                 view_runtime_max: 0,
							                 db_runtime_max: 0,
							                 duration_max: 0
                                           }
        monitoring[controller] ||= { number_of_requests_in_hour: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                                     number_of_requests: 0,
                                     view_runtime_max: 0,
                                     db_runtime_max: 0,
                                     duration_max: 0
	                               }
        #summary
        monitoring[:controller][:controllers_list] << controller unless monitoring[:controller][:controllers_list].include?(controller)
        monitoring[:controller][:number_of_requests_in_hour][timestamp_hour] ||= 0
        monitoring[:controller][:number_of_requests_in_hour][timestamp_hour] += 1 
        monitoring[:controller][:number_of_requests] += 1 
        monitoring[:controller][:view_runtime_max] = view_runtime if monitoring[:controller][:view_runtime_max] < (view_runtime || 0)
        monitoring[:controller][:db_runtime_max]   = db_runtime   if monitoring[:controller][:db_runtime_max] < (db_runtime || 0)
        monitoring[:controller][:duration_max]     = duration     if monitoring[:controller][:duration_max] < (duration || 0)

        monitoring[:controller]["number_of_#{status}"]   ||= 0
        monitoring[:controller]["number_of_#{status}"]   +=1


        #summary controller
        monitoring[controller][:number_of_requests_in_hour][timestamp_hour] ||= 0 
        monitoring[controller][:number_of_requests_in_hour][timestamp_hour] += 1 
        monitoring[controller][:number_of_requests] += 1 
        monitoring[controller][:view_runtime_max] = view_runtime if monitoring[controller][:view_runtime_max] < (view_runtime || 0)
        monitoring[controller][:db_runtime_max]   = db_runtime   if monitoring[controller][:db_runtime_max] < (db_runtime || 0)
        monitoring[controller][:duration_max]     = duration     if monitoring[controller][:duration_max] < (duration || 0)

        monitoring[controller]["number_of_#{status}"]   ||= 0
        monitoring[controller]["number_of_#{status}"]   +=1
        
        #summary controller action
        monitoring[controller_action][:number_of_requests_in_hour][timestamp_hour] ||= 0
        monitoring[controller_action][:number_of_requests_in_hour][timestamp_hour] += 1
        monitoring[controller_action][:number_of_requests] += 1
        monitoring[controller_action][:view_runtime_max] = view_runtime if monitoring[controller_action][:view_runtime_max] < (view_runtime || 0)
        monitoring[controller_action][:db_runtime_max]   = db_runtime   if monitoring[controller_action][:db_runtime_max] < (db_runtime || 0)
        monitoring[controller_action][:duration_max]     = duration if monitoring[controller_action][:duration_max] < (duration || 0)
 
        monitoring[controller_action]["number_of_#{status}"]   ||= 0
        monitoring[controller_action]["number_of_#{status}"]   +=1
                                 

      end#if "process_action.action_controller"

      #severity
      monitoring[:severity][:number_of_error]   += 1 if severity == "ERROR"
      monitoring[:severity][:number_of_fatal]   += 1 if severity == "FATAL"
      monitoring[:severity][:number_of_unknown] += 1 if severity == "UNKNOWN"
      monitoring[:severity][:number_of_warn]    += 1 if severity == "WARN"

    end#IO.foreach("./log/development.log") do |x| 
    byebug
  end#task :parse_log_file => :environment do
end

