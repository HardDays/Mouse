class DeleteDateToFromArtistDates < ActiveRecord::Migration[5.1]
  def change
    remove_column :artist_dates, :end_date, :datetime
    rename_column :artist_dates, :begin_date, :date
  end
end
