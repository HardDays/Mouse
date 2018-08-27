class CreateQuestionReplies < ActiveRecord::Migration[5.1]
  def change
    create_table :question_replies do |t|
      t.string :subject
      t.string :message
      t.integer :admin_id
      t.integer :question_id

      t.timestamps
    end
  end
end
