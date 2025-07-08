# == Schema Information
#
# Table name: sensors
#
#  id          :bigint           not null, primary key
#  location    :string
#  name        :string
#  sensor_type :string
#  status      :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Sensor < ApplicationRecord
  enum :status, {
    active: 0,
    offline: 1
  }, suffix: true
end
