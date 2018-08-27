class CreateAdmins < ActiveRecord::Migration[5.1]
  def change
    create_table :admins do |t|
      t.string :address
      t.string :address_other
      t.integer :user_id
      t.string :country
      t.string :city
      t.string :state

      t.timestamps
    end

    add_column :users, :is_admin, :boolean, default: false
  end
end
