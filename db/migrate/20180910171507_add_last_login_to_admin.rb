class AddLastLoginToAdmin < ActiveRecord::Migration[5.1]
  def change
    add_column :admins, :last_logn, :datetime
  end
end
