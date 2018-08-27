class CreateAccountUpdates < ActiveRecord::Migration[5.1]
  def change
    create_table :account_updates do |t|
      t.integer :account_id
      t.integer :updated_by
      t.integer :action
      t.integer :field

      t.timestamps
    end
  end
end
