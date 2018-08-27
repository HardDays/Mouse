class ChangeQuestions < ActiveRecord::Migration[5.1]
  def change
    rename_column :questions, :user_id, :account_id
  end
end
