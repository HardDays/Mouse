class ChangeCommentsTimestamps < ActiveRecord::Migration[5.1]
  def change
    remove_column :comments, :created_at, :datetime, null: false, default: Time.now
    remove_column :comments, :updated_at, :datetime, null: false, default: Time.now

    add_column :comments, :created_at, :datetime, null: false
    add_column :comments, :updated_at, :datetime, null: false
  end
end
