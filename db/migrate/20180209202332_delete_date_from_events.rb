class DeleteDateFromEvents < ActiveRecord::Migration[5.1]
  def change
    remove_column :events, :date
  end
end
