class ChangeDescLimitAtEvent < ActiveRecord::Migration[5.1]
  def change
    change_column :events, :description, :string, :limit => 500
  end
end
