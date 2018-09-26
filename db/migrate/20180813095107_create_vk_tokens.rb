class CreateVkTokens < ActiveRecord::Migration[5.1]
  def change
    create_table :vk_tokens do |t|
      t.string :user_id
      t.string :token

      t.timestamps
    end
  end
end
