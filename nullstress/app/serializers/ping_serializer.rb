class PingSerializer
  include JSONAPI::Serializer

  set_type :ping

  attributes :sensor_id,
    :status_code,
    :response_time,
    :created_at,
    :updated_at
end
