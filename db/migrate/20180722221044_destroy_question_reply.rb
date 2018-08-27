class DestroyQuestionReply < ActiveRecord::Migration[5.1]
  def change
    drop_table :question_replies

    add_column :questions, :message_id, :integer
    add_column :feedbacks, :message_id, :integer
  end
end
