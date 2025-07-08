class DropStatusFromSensors < ActiveRecord::Migration[8.0]
  def change
    remove_column :sensors, :status, :string
  end
end
