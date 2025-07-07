class CreatePings < ActiveRecord::Migration[8.0]
  def change
    create_table :pings do |t|
      t.references :sensor, null: false, foreign_key: true
      t.integer :status_code
      t.float :response_time

      t.timestamps
    end

    add_index :pings, [:sensor_id, :created_at]
    add_index :pings, [:sensor_id, :status_code]
    add_index :pings, :created_at
  end
end
