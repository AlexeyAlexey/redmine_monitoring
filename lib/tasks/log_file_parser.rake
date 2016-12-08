namespace :monitoring do
  desc 'Log parser
    RAILS_ENV=production rake monitoring:statistic_parse_log_file log_file_path="./log/production.log" day=10 month=11 year=2016
  '
  #RAILS_ENV=production rake monitoring:statistic_parse_log_file log_file_path="./log/production.log" project_id=1 day=10 month=11 year=2016 severity_types=ERROR,FATAL,WARN,INFO,DEBUG
  #RAILS_ENV=production rake monitoring:statistic_parse_log_file log_file_path="./log/production.log" 
  task :statistic_parse_log_file => :environment do
    project_id    = ENV["project_id"]

    log_file_path = ENV['log_file_path']
    severity_types_param  = ENV['severity_types'].split(',')
    time_now = Time.now

    day   = (ENV['day']   || (time_now.day - 1)).to_i
    month = (ENV['month'] || time_now.month).to_i
    year  = (ENV['year']  || time_now.year).to_i

    indexes = {}
    controller_action_severity = {}

    unless severity_types_param.blank?
      indexes = LogFileParser.create_indexes(day, month, year, log_file_path)
      
      controllers = indexes.keys
      controllers.delete("severity")

      indexes_severity = indexes["severity"]
      controllers.each do |controller|
        actions = indexes[controller].keys
        indexes_severity.each do |info_type, request_unique_ids|
          if severity_types_param.include?(info_type)
            actions.each do |action|
              action_request_unique_ids = indexes[controller][action]

              number_of_types = (request_unique_ids & action_request_unique_ids).size
              if number_of_types > 0
                #init
                controller_action_severity[controller]                     ||= {}
                controller_action_severity[controller][action]             ||= {}
                controller_action_severity[controller][action][info_type] = number_of_types

                controller_action_severity[controller]["__severity__"]            ||= {}
                controller_action_severity[controller]["__severity__"][info_type] ||= 0
                controller_action_severity[controller]["__severity__"][info_type] += number_of_types

              end
            end
          end
        end
      end
    end
    #controller_action_severity = {"IssuesController"=>{"create"=>{"ERROR"=>1}}}
    #{"IssuesController"=>{"index"=>{"INFO"=>5}, "create"=>{"INFO"=>2, "ERROR"=>1}}}
    indexes = {}
  	monitoring = {controllers: {	number_of_requests_in_hour: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
							                  number_of_requests: 0,
							                  view_runtime_max: 0,
							                  db_runtime_max: 0,
							                  duration_max: 0,
                                statuses: {}
							                },
				          severity: { }
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

        monitoring[controller][:controller]["severity"] ||= {} 
        monitoring[controller][:controller]["severity"] = controller_action_severity.try(:[], controller).try(:[], "__severity__") || {}
        
        #monitoring["WelcomeController"]["index"]
        monitoring[controller][action][:number_of_requests_in_hour][timestamp_hour] ||= 0
        monitoring[controller][action][:number_of_requests_in_hour][timestamp_hour] += 1
        monitoring[controller][action][:number_of_requests] += 1
        monitoring[controller][action][:view_runtime_max] = view_runtime if monitoring[controller][action][:view_runtime_max] < (view_runtime || 0)
        monitoring[controller][action][:db_runtime_max]   = db_runtime   if monitoring[controller][action][:db_runtime_max] < (db_runtime || 0)
        monitoring[controller][action][:duration_max]     = duration     if monitoring[controller][action][:duration_max] < (duration || 0)
 
        monitoring[controller][action][:statuses]["#{status}"]   ||= 0
        monitoring[controller][action][:statuses]["#{status}"]   +=1
                                 
        monitoring[controller][action][:severity] = controller_action_severity.try(:[], controller).try(:[], action) || {}
        
      end#if "process_action.action_controller"

      #severity
      if timestamp_day == day and timestamp_month == month and timestamp_year == year
        if severity_types_param.include?(severity)
          monitoring[:severity][severity] ||= 0
          monitoring[:severity][severity] += 1
        end
        #monitoring[:severity][:number_of_error]   += 1 if severity == "ERROR"
        #monitoring[:severity][:number_of_fatal]   += 1 if severity == "FATAL"
        #monitoring[:severity][:number_of_unknown] += 1 if severity == "UNKNOWN"
        #monitoring[:severity][:number_of_warn]    += 1 if severity == "WARN"
      end
    end#IO.foreach("./log/production.log") do |x| 

    time_now = Time.now
    if !project_id.blank?
      MonitoringResult.create(project_id: project_id, monitoring_day: Time.new(year, month, day, time_now.hour).to_s(:db), result: monitoring)
    else
      puts monitoring
    end
  end#task :parse_log_file => :environment do

  #RAILS_ENV=production rake monitoring:read_and_write_into_console log_file_path="./log/production.log"  >  ./log/development_wr.log
  task :read_and_write_into_console => :environment do

    #file_path = "./log/production.log"
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
  #tail -f production.log
  #RAILS_ENV=production rake monitoring:tail_f log_file_path="./log/production.log"
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
  #rake monitoring:read_and_write_into_db log_file_path="./log/production.log" begin_hour=1 begin_day=10 begin_month=11 begin_year=2016
  task :read_and_write_into_db => :environment do
    #file_path = "./log/production.log"
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
  #rake monitoring:read_and_write_into_redis log_file_path="./log/production.log" begin_hour=1 begin_day=10 begin_month=11 begin_year=2016 redis_url='redis://localhost:6379/11' redis_queue='redmine_monitoring'
  task :read_and_write_into_redis => :environment do
     
    #file_path = "./log/production.log"
    log_file_path = ENV['log_file_path']
    begin_hour    = ENV['begin_hour'].to_i
    begin_day     = ENV['begin_day'].to_i
    begin_month   = ENV['begin_month'].to_i
    begin_year    = ENV['begin_year'].to_i
    redis_url     = ENV['redis_url']
    redis_queue   = ENV["redis_queue"]

    redis_connection_pool = ConnectionPool.new({size: 5, timeout: 5}) { Redis.new(:url => redis_url) }

    
    IO.foreach(log_file_path) do |x| 
      line = {}
      begin
        line = JSON.parse(x)
      rescue Exception => e
        
      end
      
      unless line.empty?
        severity        = line["severity"]
        timestamp_str   = line["@timestamp"] || line["time"]
        begin_timestamp       = Time.parse(timestamp_str)
        begin_timestamp_hour  = Time.parse(timestamp_str).hour
        begin_timestamp_day   = Time.parse(timestamp_str).day
        begin_timestamp_month = Time.parse(timestamp_str).month
        begin_timestamp_year  = Time.parse(timestamp_str).year
      end
      if !line.empty? and begin_timestamp_hour >= begin_hour and begin_timestamp_day == begin_day and begin_timestamp_month == begin_month and begin_timestamp_year == begin_year
        redis_connection_pool.with do |redis|
          redis.lpush redis_queue, line.to_json
        end

      end
    end#IO.foreach(file_path) do |x| 
  end
  #rake monitoring:stream_to_redis log_file_path="./log/production.log" redis_url='redis://localhost:6379/11' redis_queue='redmine_monitoring'
  task :stream_to_redis => :environment do

    log_file_path = ENV['log_file_path']
    redis_url     = ENV['redis_url']
    redis_queue   = ENV["redis_queue"]

    redis_connection_pool = ConnectionPool.new({size: 5, timeout: 5}) { Redis.new(:url => redis_url) }

    x = open("|tail -f #{log_file_path}")
    loop do 
      line = {}
      begin
        line = JSON.parse(x.gets)
      rescue Exception => e
      
      end

      if !line.empty?
        redis_connection_pool.with do |redis|
          redis.lpush redis_queue, line.to_json
        end
      end
    end
  end
  #RAILS_ENV=production rake monitoring:find log_file_path="./log/production.log" output_folder_path="./log/2" controler='MonitoringResultsController' severity='ERROR'
  #RAILS_ENV=development rake monitoring:find log_file_path="./log/development.log" output_folder_path="./log/2" controler='MonitoringResultsController' severity='FATAL'
  task :find => :environment do
     
    #file_path = "./log/production.log"
    output_folder_path = ENV['output_folder_path']
    log_file_path = ENV['log_file_path']
    controler     = ENV['controler']
    severity      = ENV['severity']
  
    controler_request_unique_id = {}
    severity_request_unique_id  = {}
    
    
    IO.foreach(log_file_path) do |x| 
      line = {}
      begin
        line = JSON.parse(x)
      rescue Exception => e
        
      end
      
      unless line.empty?
        request_unique_id = line["request_unique_id"]
        if line["name"] == "process_action.action_controller" and line["payload"]["controller"] == controler and !request_unique_id.blank?
          controler_request_unique_id[request_unique_id] = ""
        elsif !request_unique_id.blank? and line["severity"] == severity
          severity_request_unique_id[request_unique_id] = ""
        end
        
      end
      
    end#IO.foreach(file_path) do |x| 
    request_unique_ids = Hash[ *(severity_request_unique_id.keys & controler_request_unique_id.keys).map{|el| [el, File.new("#{output_folder_path}/#{el}.txt", "a")]}.flatten ]
    
    IO.foreach(log_file_path) do |x| 
      line = {}
      begin
        line = JSON.parse(x)
      rescue Exception => e
        
      end
      
      unless line.empty?
        request_unique_id = line["request_unique_id"]
        if request_unique_ids.has_key?(request_unique_id)
           #if line["name"] == "process_action.action_controller"
             request_unique_ids[request_unique_id].puts(line.to_json)
           #else
             #request_unique_ids[request_unique_id].puts(line["message"])
           #end
        end
      end
      
    end#IO.foreach(file_path) do |x| 
   

  end#task :find => :environment
  #developing
  #RAILS_ENV=production rake monitoring:create_indexes log_file_path="./log/production.log" output_folder_path="./log/2" day=30 month=11 year=2016
  # RAILS_ENV=development rake monitoring:create_indexes log_file_path="./log/development.log" output_folder_path="./log/2" day=30 month=11 year=2016
  task :create_indexes => :environment do
     
    #file_path = "./log/production.log"
    output_folder_path = ENV['output_folder_path']
    log_file_path      = ENV['log_file_path']

    time_now = Time.now

    day   = (ENV['day']   || (time_now.day - 1)).to_i
    month = (ENV['month'] || time_now.month).to_i
    year  = (ENV['year']  || time_now.year).to_i
  
    
    LogFileParser.create_indexes(day, month, year, log_file_path, output_folder_path)
  end#task :create_indexes => :environment 
end


module LogFileParser
  def self.create_indexes(day, month, year, log_file_path, output_folder_path = nil)
    indexes = {}
    
    
    IO.foreach(log_file_path) do |x| 
      line = {}
      begin
        line = JSON.parse(x)
      rescue Exception => e
        
      end
      
      unless line.empty?
        timestamp_str   = line["@timestamp"] || line["time"]
        timestamp       = Time.parse(timestamp_str)
        timestamp_hour  = timestamp.hour
        timestamp_day   = timestamp.day
        timestamp_month = timestamp.month
        timestamp_year  = timestamp.year

        request_unique_id = line["request_unique_id"]
        if timestamp_day == day and timestamp_month == month and timestamp_year == year and !request_unique_id.blank?
          if line["name"] == "process_action.action_controller" 
            controller_name = line["payload"]["controller"]
            action_name     = line["payload"]["action"]

            indexes[controller_name] ||= {}
            indexes[controller_name][action_name] ||= {}

            indexes[controller_name][action_name][request_unique_id] = ""
            
          else
            severity = line["severity"]
            indexes["severity"] ||= {}
            indexes["severity"][severity] ||= {}
            indexes["severity"][severity][request_unique_id] = ""
          end
        end#if timestamp_day == day and timestamp_month == month and timestamp_year == year
      end
      
    end#IO.foreach(file_path) do |x| 
    
    indexes_keys = indexes.keys
    indexes_keys.each do |key|
      indexes_keys_keys = indexes[key].keys
      indexes_keys_keys.each do |key_key|
        indexes[key][key_key] = indexes[key][key_key].keys
      end
    end
    unless output_folder_path.nil?
      file = File.new("#{output_folder_path}/indexes.txt", "a")
      file.puts indexes.to_json
    end
    #indexes = {controller_name => {action_name => [request_unique_ids]},
    #           "severity" => {serverity_type => [request_unique_ids]}
    #          }
    indexes
  end
  
end
  

