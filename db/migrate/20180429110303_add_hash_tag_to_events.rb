class AddHashTagToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :hashtag, :string
  end
end
