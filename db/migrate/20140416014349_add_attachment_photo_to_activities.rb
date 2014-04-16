class AddAttachmentPhotoToActivities < ActiveRecord::Migration
  def self.up
    change_table :activities do |t|
      t.attachment :photo
    end
  end

  def self.down
    drop_attached_file :activities, :photo
  end
end
