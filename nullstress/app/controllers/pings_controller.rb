class PingsController < ApplicationController
  def index
    head :not_implemented
  end

  def create
    ping = Ping.new(ping_params)

    if ping.save
      render json: PingSerializer.new(ping).serializable_hash, status: :created
    else
      render json: { errors: ping.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def ping_params
    params.require(:ping).permit(:sensor_id, :response_time, :status_code)
  end

end
