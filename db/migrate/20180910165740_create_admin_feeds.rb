class CreateAdminFeeds < ActiveRecord::Migration[5.1]
  def change
    create_table :admin_feeds do |t|
      t.integer :action
      t.integer :value

      t.timestamps
    end
  end
end
