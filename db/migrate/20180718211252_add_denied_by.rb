class AddDeniedBy < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :denier_id, :integer
    add_column :events, :denier_id, :integer
  end
end
