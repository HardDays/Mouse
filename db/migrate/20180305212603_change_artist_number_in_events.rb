class ChangeArtistNumberInEvents < ActiveRecord::Migration[5.1]
  def change
    change_column :events, :artists_number, :integer, default: 6
  end
end
