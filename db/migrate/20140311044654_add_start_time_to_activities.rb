class AddStartTimeToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :start_time, :datetime
  end
end
