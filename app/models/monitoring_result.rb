class MonitoringResult < ActiveRecord::Base
  unloadable
  self.skip_time_zone_conversion_for_attributes = [:monitoring_day]

  serialize :result, JSON
end
