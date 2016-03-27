class CreateLoadStatuses < ActiveRecord::Migration
  def change
    create_table :load_statuses do |t|
      t.boolean :start
      t.boolean :finish
      t.string :error

      t.timestamps null: false
    end
  end
end
