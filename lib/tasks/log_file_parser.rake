namespace :monitoring do
  desc 'Log parser
    rake monitoring:statistic_parse_log_file log_file_path="./log/development.log" day=10 month=11 year=2016 project_id=1 server_id=1
  '
  #rake monitoring:statistic_parse_log_file log_file_path="./log/development.log" day=10 month=11 year=2016 project_id=1
  task :statistic_parse_log_file => :environment do
    log_file_path = ENV['log_file_path']
    day   = ENV['day'].to_i
    month = ENV['month'].to_i
    year  = ENV['year'].to_i

    project_id = ENV['project_id'].to_i
    server_id  = ENV['server_id'].to_i
  	
  	monitoring = {controllers: {	number_of_requests_in_hour: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
							                  number_of_requests: 0,
							                  view_runtime_max: 0,
							                  db_runtime_max: 0,
							                  duration_max: 0,
                                statuses: {}
							                },
				          severity: { number_of_error: 0,
					  	  	            number_of_fatal: 0,
							                number_of_unknown: 0,
							                number_of_warn: 0
							  }
		         }
    

    IO.foreach(log_file_path) do |x| 
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
      	action     = "#{line["payload"]["action"]}"
		
		    status       = line["payload"]["status"]# => 200
		    view_runtime = line["payload"]["view_runtime"]#=> 2742.154952
		    db_runtime   = line["payload"]["db_runtime"]#=> 51.33422399999999
		    duration     = line["duration"]
		
        monitoring[controller] ||= {}
        monitoring[controller][:controller] ||= {number_of_requests_in_hour: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                number_of_requests: 0,
                view_runtime_max: 0,
                db_runtime_max: 0,
                duration_max: 0,
                statuses: {}
               }

      	monitoring[controller][action] ||= {number_of_requests_in_hour: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                number_of_requests: 0,
                view_runtime_max: 0,
                db_runtime_max: 0,
                duration_max: 0,
                statuses: {}
               }

        
        #summary
        monitoring[:controllers][:number_of_requests_in_hour][timestamp_hour] ||= 0
        monitoring[:controllers][:number_of_requests_in_hour][timestamp_hour] += 1 
        monitoring[:controllers][:number_of_requests] += 1 
        monitoring[:controllers][:view_runtime_max] = view_runtime if monitoring[:controllers][:view_runtime_max] < (view_runtime || 0)
        monitoring[:controllers][:db_runtime_max]   = db_runtime   if monitoring[:controllers][:db_runtime_max] < (db_runtime || 0)
        monitoring[:controllers][:duration_max]     = duration     if monitoring[:controllers][:duration_max] < (duration || 0)

        monitoring[:controllers][:statuses]["#{status}"]   ||= 0
        monitoring[:controllers][:statuses]["#{status}"]   +=1


        #summary controller
        monitoring[controller][:controller][:number_of_requests_in_hour][timestamp_hour] ||= 0 
        monitoring[controller][:controller][:number_of_requests_in_hour][timestamp_hour] += 1 
        monitoring[controller][:controller][:number_of_requests] += 1 
        monitoring[controller][:controller][:view_runtime_max] = view_runtime if monitoring[controller][:controller][:view_runtime_max] < (view_runtime || 0)
        monitoring[controller][:controller][:db_runtime_max]   = db_runtime   if monitoring[controller][:controller][:db_runtime_max] < (db_runtime || 0)
        monitoring[controller][:controller][:duration_max]     = duration     if monitoring[controller][:controller][:duration_max] < (duration || 0)

        monitoring[controller][:controller][:statuses]["#{status}"]   ||= 0
        monitoring[controller][:controller][:statuses]["#{status}"]   +=1
        
        #monitoring["WelcomeController"]["index"]
        monitoring[controller][action][:number_of_requests_in_hour][timestamp_hour] ||= 0
        monitoring[controller][action][:number_of_requests_in_hour][timestamp_hour] += 1
        monitoring[controller][action][:number_of_requests] += 1
        monitoring[controller][action][:view_runtime_max] = view_runtime if monitoring[controller][action][:view_runtime_max] < (view_runtime || 0)
        monitoring[controller][action][:db_runtime_max]   = db_runtime   if monitoring[controller][action][:db_runtime_max] < (db_runtime || 0)
        monitoring[controller][action][:duration_max]     = duration     if monitoring[controller][action][:duration_max] < (duration || 0)
 
        monitoring[controller][action][:statuses]["#{status}"]   ||= 0
        monitoring[controller][action][:statuses]["#{status}"]   +=1
                                 

      end#if "process_action.action_controller"

      #severity
      if timestamp_day == day and timestamp_month == month and timestamp_year == year
        monitoring[:severity][:number_of_error]   += 1 if severity == "ERROR"
        monitoring[:severity][:number_of_fatal]   += 1 if severity == "FATAL"
        monitoring[:severity][:number_of_unknown] += 1 if severity == "UNKNOWN"
        monitoring[:severity][:number_of_warn]    += 1 if severity == "WARN"
      end
    end#IO.foreach("./log/development.log") do |x| 
    
    if project_id != 0 and Redmine::Plugin.registered_plugins.include?(:redmine_monitoring_server)
      MonitoringResult.create(project_id: project_id, server_id: server_id, monitoring_day: Time.new(year, month, day).to_s, result: monitoring)
    end
  end#task :parse_log_file => :environment do

  #rake monitoring:read_and_write_into_console log_file_path="./log/development.log"  >  ./log/development_wr.log
  task :read_and_write_into_console => :environment do

    #file_path = "./log/development.log"
    log_file_path = ENV['log_file_path']

    IO.foreach(log_file_path) do |x| 
      line = {}
      begin
        line = JSON.parse(x)
      rescue Exception => e
        
      end

      if line["name"].nil?
        puts line["message"] + "  request_unique_id:#{line["request_unique_id"]}"
      end
    end#IO.foreach(file_path) do |x| 


############## not realised
    #task :read_and_write_into_console_where => :environment do

    #file_path = "./log/development.log"
    #file_path = ENV['file_path']

    #IO.foreach(file_path) do |x| 
      #print "Command: "
      #console = STDIN.gets.chomp
      
      #if console == ""
    #    line = {}
    #    begin
    #      line = JSON.parse(x)
    #
    #    rescue Exception => e
    #    
    #    end
    #    #rake monitoring:read_and_write_into_console > ./log/development_wr.log
    #    if line["name"].nil? #and line["request_unique_id"] == "17953020ce940d42ef28d1793e441478782127"
    #       puts line["message"] + "  request_unique_id:#{line["request_unique_id"]}"
    #    end
    #    
    #  #end
    #  
    #end

  end
end

