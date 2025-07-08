class SensorsController < ApplicationController
  def index
    sensors = Sensor.all.limit(params.fetch(:limit, 100).to_i)
    render json: SensorSerializer.new(sensors).serializable_hash
  end

  def show
    sensor = Sensor.find(params[:id])
    render json: SensorSerializer.new(sensor).serializable_hash
  end

  def failures
    sensor = Sensor.find(params[:id])

    scope = sensor.pings
      .where("status_code >= 500")
      .order(created_at: :desc)

    pagy, failed_pings = pagy(scope, items: params.fetch(:per_page, 100).to_i)

    render json: PingSerializer.new(failed_pings, meta: pagy_metadata(pagy)).serializable_hash
  end
end
