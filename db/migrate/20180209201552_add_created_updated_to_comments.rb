class AddCreatedUpdatedToComments < ActiveRecord::Migration[5.1]
  def change
    add_column :comments, :created_at, :datetime, null: false, default: Time.now
    add_column :comments, :updated_at, :datetime, null: false, default: Time.now
  end
end
