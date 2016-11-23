class MonitoringResult < ActiveRecord::Base
  unloadable

  serialize :result, JSON
end
