class CommentsRenameFanId < ActiveRecord::Migration[5.1]
  def change
    rename_column :comments, :fan_id, :account_id
  end
end
