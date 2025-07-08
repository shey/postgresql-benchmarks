# app/controllers/metrics/failures_controller.rb
module Metrics
  class FailuresController < ApplicationController
    def top
      recent_window = 1.hour.ago

      results = Ping
        .where("status_code >= 500 AND created_at >= ?", recent_window)
        .group(:sensor_id)
        .order("COUNT(*) DESC")
        .limit(10)
        .count

      sensors = Sensor.where(id: results.keys).index_by(&:id)

      response = results.map do |sensor_id, failure_count|
        {
          id: sensor_id,
          name: sensors[sensor_id]&.name,
          failure_count: failure_count
        }
      end

      render json: {data: response}
    end
  end
end
