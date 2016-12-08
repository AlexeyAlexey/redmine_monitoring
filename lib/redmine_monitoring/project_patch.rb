module RedmineMonitoring
  module ProjectPatch
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods

	  receiver.class_eval do 
	    unloadable
        has_many :monitoring_results, :dependent => :destroy
	  end
	end

	module ClassMethods
	end

	module InstanceMethods
	end
  end
end
