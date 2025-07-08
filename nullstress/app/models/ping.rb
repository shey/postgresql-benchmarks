# == Schema Information
#
# Table name: pings
#
#  id            :bigint           not null, primary key
#  response_time :float
#  status_code   :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  sensor_id     :bigint           not null
#
# Indexes
#
#  index_pings_on_created_at                 (created_at)
#  index_pings_on_sensor_id                  (sensor_id)
#  index_pings_on_sensor_id_and_created_at   (sensor_id,created_at)
#  index_pings_on_sensor_id_and_status_code  (sensor_id,status_code)
#
# Foreign Keys
#
#  fk_rails_...  (sensor_id => sensors.id)
#
class Ping < ApplicationRecord
  belongs_to :sensor
end
