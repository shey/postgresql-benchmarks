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
class Sensor < ApplicationRecord
  has_many :pings
end
