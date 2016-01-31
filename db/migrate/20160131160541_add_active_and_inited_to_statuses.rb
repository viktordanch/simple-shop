class AddActiveAndInitedToStatuses < ActiveRecord::Migration
  def change
    add_column :statuses, :active, :boolean
    add_column :statuses, :inited, :boolean
  end
end
