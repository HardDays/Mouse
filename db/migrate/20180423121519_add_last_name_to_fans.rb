class AddLastNameToFans < ActiveRecord::Migration[5.1]
  def change
    add_column :fans, :last_name, :string
  end
end
