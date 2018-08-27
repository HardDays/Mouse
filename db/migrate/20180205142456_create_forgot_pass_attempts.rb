class CreateForgotPassAttempts < ActiveRecord::Migration[5.1]
  def change
    create_table :forgot_pass_attempts do |t|
      t.integer :user_id
      t.integer :attempt_count

      t.timestamps
    end
  end
end
