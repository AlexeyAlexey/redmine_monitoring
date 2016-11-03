namespace :monitoring do
  desc 'Log parser'
  task :parse_log_file => :environment do
    IO.foreach("./log/development.log") do |x| 
      line = JSON.parse(x)
      if line["name"] == "process_action.action_controller"
      end
    end
  end
end
