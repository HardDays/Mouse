class ChangeColumnUserAtFeedback < ActiveRecord::Migration[5.1]
  def change
    rename_column :feedbacks, :user_id, :account_id
  end
end
