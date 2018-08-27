class RenameVideoLinks < ActiveRecord::Migration[5.1]
  def change
    rename_table :account_video_links, :artist_videos
    rename_column :artist_videos, :account_id, :artist_id
  end
end
