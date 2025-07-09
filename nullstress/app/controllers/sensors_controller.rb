class SensorsController < ApplicationController
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

  def failure_rate
    sensor = Sensor.find(params[:id])
    recent_pings = sensor.pings.where("created_at >= ?", 1.hour.ago)

    total = recent_pings.count
    failures = recent_pings.where("status_code >= 500").count

    rate = total.zero? ? 0.0 : (failures.to_f / total * 100).round(2)

    render json: {
      data: {
        type: "failure_rate",
        id: sensor.id.to_s,
        attributes: {rate: rate, total: total, failures: failures}
      }
    }
  end

  def recent_failures
    sensor = Sensor.find(params[:id])

    failed_pings = sensor.pings
      .where("status_code >= 500")
      .order(created_at: :desc)

    pagy, pings = pagy(failed_pings, items: params.fetch(:per_page, 100).to_i)

    render json: PingSerializer.new(pings, meta: pagy_metadata(pagy)).serializable_hash
  end

  def hourly_stats
    sensor = Sensor.find(params[:id])

    stats = sensor.pings
      .where("created_at >= ?", 24.hours.ago)
      .group("date_trunc('hour', created_at)")
      .select(
        "date_trunc('hour', created_at) as hour",
        "count(*) as total",
        "count(*) FILTER (WHERE status_code >= 500) as failures",
        "avg(response_time) as avg_response_time"
      )
      .order("hour ASC")

    data = stats.map do |row|
      {
        hour: row.hour.iso8601,
        total: row.total.to_i,
        failures: row.failures.to_i,
        avg_response_time: row.avg_response_time.to_f.round(2)
      }
    end

    render json: {data: data}
  end

  def recent_pings
    sensor = Sensor.find(params[:id])

    recent = sensor.pings
      .order(created_at: :desc)
      .limit(params.fetch(:limit, 20).to_i)

    render json: PingSerializer.new(recent).serializable_hash
  end

  def latency_summary
    sensor = Sensor.find(params[:id])

    stats = sensor.pings
      .where("created_at >= ?", 1.hour.ago)
      .pluck(:response_time)

    if stats.empty?
      render json: {
        data: {
          type: "latency_summary",
          id: sensor.id.to_s,
          attributes: {}
        }
      }
      return
    end

    summary = {
      avg: stats.mean.round(2),
      median: stats.median.round(2),
      p95: stats.percentile(95).round(2),
      p99: stats.percentile(99).round(2),
      stddev: stats.standard_deviation.round(2)
    }

    render json: {
      data: {
        type: "latency_summary",
        id: sensor.id.to_s,
        attributes: summary
      }
    }
  end

  private

  def pagy_metadata(pagy)
    {
      current_page: pagy.page,
      total_pages: pagy.pages,
      total_count: pagy.count,
      per_page: pagy.vars[:items]
    }
  end
end
