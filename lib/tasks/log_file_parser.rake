namespace :monitoring do
  desc 'Log parser
    rake monitoring:statistic_parse_log_file log_file_path="./log/development.log" day=10 month=11 year=2016
  '
  #rake monitoring:statistic_parse_log_file log_file_path="./log/development.log" day=10 month=11 year=2016
  task :statistic_parse_log_file => :environment do
    log_file_path = ENV['log_file_path']
    day   = ENV['day'].to_i
    month = ENV['month'].to_i
    year  = ENV['year'].to_i

      	
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
    
    MonitoringResult.create(monitoring_day: Time.new(year, month, day).to_s, result: monitoring)
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
  end
  #tail -f development.log
  #rake monitoring:tail_f log_file_path="./log/development.log"
  task :tail_f => :environment do

    log_file_path = ENV['log_file_path']
    x = open("|tail -f #{log_file_path}")
    loop do 
      line = {}
      begin
        line = JSON.parse(x.gets)
      rescue Exception => e
      
      end

      if line["name"].nil?
        puts line["message"] #+ "  request_unique_id:#{line["request_unique_id"]}"
      end
    end
  end
  #rake monitoring:read_and_write_into_db log_file_path="./log/development.log" begin_hour=1 begin_day=10 begin_month=11 begin_year=2016
  task :read_and_write_into_db => :environment do
    #file_path = "./log/development.log"
    log_file_path = ENV['log_file_path']
    begin_hour    = ENV['begin_hour'].to_i
    begin_day     = ENV['begin_day'].to_i
    begin_month   = ENV['begin_month'].to_i
    begin_year    = ENV['begin_year'].to_i

    
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
      if begin_timestamp_hour == begin_hour and begin_timestamp_day == begin_day and begin_timestamp_month == begin_month and begin_timestamp_year == begin_year
        if line["name"] == "process_action.action_controller"
          
        end
      end
    end#IO.foreach(file_path) do |x| 
  end
  #rake monitoring:read_and_write_into_redis log_file_path="./log/development.log" begin_hour=1 begin_day=10 begin_month=11 begin_year=2016
  task :read_and_write_into_redis => :environment do
    #file_path = "./log/development.log"
    log_file_path = ENV['log_file_path']
    begin_hour    = ENV['begin_hour'].to_i
    begin_day     = ENV['begin_day'].to_i
    begin_month   = ENV['begin_month'].to_i
    begin_year    = ENV['begin_year'].to_i

    
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
      if begin_timestamp_hour == begin_hour and begin_timestamp_day == begin_day and begin_timestamp_month == begin_month and begin_timestamp_year == begin_year
        
      end
    end#IO.foreach(file_path) do |x| 
  end
end

