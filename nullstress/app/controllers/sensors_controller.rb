class SensorsController < ApplicationController
  include Pagy::Backend

  def index
    sensors = Sensor.order(created_at: :desc)
    pagy, records = pagy(sensors, items: params.fetch(:per_page, 100).to_i)

    render json: SensorSerializer.new(
      records, meta: pagy_metadata(pagy)
    ).serializable_hash
  end

  def show
    sensor = Sensor.find(params[:id])
    render json: SensorSerializer.new(sensor).serializable_hash
  end

  def stats
    sensor = Sensor.find(params[:id])

    recent_pings = sensor.pings.where("created_at >= ?", 24.hours.ago)

    total = recent_pings.count
    failures = recent_pings.where("status_code >= 500").count
    avg_response = recent_pings.average(:response_time)

    stats = {
      uptime_percent: total.zero? ? 100.0 : (((total - failures).to_f / total) * 100).round(2),
      avg_response_time: avg_response.to_f.round(2)
    }

    # mimics openapi response structure
    render json: {
      data: {
        type: "sensor_stats",
        id: sensor.id.to_s,
        attributes: stats
      }
    }
  end

  def failures
    sensor = Sensor.find(params[:id])

    failed_pings = sensor.pings
      .where("status_code >= 500")
      .order(created_at: :desc)

    pagy, records = pagy(failed_pings, items: params.fetch(:per_page, 100).to_i)

    render json: SensorSerializer.new(
      records, meta: pagy_metadata(pagy)
    ).serializable_hash
  end

  private

  def pagy_metadata(pagy)
    {
      current_page: pagy.page,
      per_page: pagy.items,
      total_pages: pagy.pages,
      total_count: pagy.count
    }
  end
end
