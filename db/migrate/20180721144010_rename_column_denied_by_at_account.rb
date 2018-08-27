class RenameColumnDeniedByAtAccount < ActiveRecord::Migration[5.1]
  def change
    rename_column :accounts, :denier_id, :processed_by
  end
end
