class AddVideoLinkToEvent < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :video_link, :string
  end
end
