class RevertRegistrationFields < ActiveRecord::Migration[5.1]
  def change
    add_column :admins, :first_name, :string
    add_column :admins, :last_name, :string
    add_column :admins, :user_name, :string
  end
end
