module RedmineMonitoring
  class RedmineMonitoringMiddleware
	
	def initialize(app)
	  @app = app
	end

	def call(env)
	  RequestStore.store[:request_unique_id] = "#{Rails.object_id}" + SecureRandom.hex(10) + "#{Time.now.utc.to_i}"

	  @status, @headers, @response = @app.call(env)
      [@status, @headers, @response]
    end
  end
end