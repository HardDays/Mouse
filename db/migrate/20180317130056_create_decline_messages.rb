class CreateDeclineMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :decline_messages do |t|
      t.integer :reason
      t.string :additional_text

      t.timestamps
    end
  end
end
