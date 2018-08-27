class CreateAccountVideoLinks < ActiveRecord::Migration[5.1]
  def change
    create_table :account_video_links do |t|
      t.integer :account_id
      t.string :link

      t.timestamps
    end
  end
end
