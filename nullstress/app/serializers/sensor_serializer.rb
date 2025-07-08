# == Schema Information
#
# Table name: sensors
#
#  id          :bigint           not null, primary key
#  location    :string
#  name        :string
#  sensor_type :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class SensorSerializer
  include JSONAPI::Serializer

  attributes :id, :name, :sensor_type, :location, :created_at, :updated_at
end
