class CreateFeedbacks < ActiveRecord::Migration[5.1]
  def change
    create_table :feedbacks do |t|
      t.integer :feedback_type
      t.string :detail, default: ''
      t.integer :rate_score
      t.integer :user_id

      t.timestamps
    end
  end
end
