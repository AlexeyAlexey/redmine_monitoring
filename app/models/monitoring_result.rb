class MonitoringResult < ActiveRecord::Base
  unloadable
  self.skip_time_zone_conversion_for_attributes = [:monitoring_day]

  belongs_to :project

  serialize :result, JSON
end
