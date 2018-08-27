class AddViewsClicksToEvent < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :views, :integer, default: false
    add_column :events, :clicks, :integer, default: false
  end
end
