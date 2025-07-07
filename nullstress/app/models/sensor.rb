class Sensor < ApplicationRecord
  enum :status, {
    active: 0,
    offline: 1
  }, suffix: true
end
