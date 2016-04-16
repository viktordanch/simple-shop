class CreateContactUs < ActiveRecord::Migration
  def change
    create_table :contact_us do |t|
      t.string :email
      t.string :topic
      t.text :comment

      t.timestamps null: false
    end
  end
end
