class AddViewedToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :is_viewed, :boolean, default: false
  end
end
