class AddFirstNameToFans < ActiveRecord::Migration[5.1]
  def change
    add_column :fans, :first_name, :string
  end
end
