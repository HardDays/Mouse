class CreateQuestions < ActiveRecord::Migration[5.1]
  def change
    create_table :questions do |t|
      t.integer :user_id
      t.string :subject
      t.string :message

      t.timestamps
    end
  end
end
