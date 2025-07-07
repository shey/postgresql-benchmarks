class CreateSensors < ActiveRecord::Migration[8.0]
  def change
    create_table :sensors do |t|
      t.string :name
      t.string :location
      t.string :sensor_type
      t.integer :status

      t.timestamps
    end
  end
end
