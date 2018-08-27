class RenameColumnDenierIdInEvents < ActiveRecord::Migration[5.1]
  def change
    rename_column :events, :denier_id, :processed_by
  end
end
