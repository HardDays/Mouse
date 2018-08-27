class AddFiledsToVenueDates < ActiveRecord::Migration[5.1]
  def change
    remove_column :venue_dates, :begin_date, :datetime
    remove_column :venue_dates, :end_date, :datetime
    remove_column :venue_dates, :booking_notice, :integer
    remove_column :venue_dates, :price, :integer
    remove_column :venue_dates, :is_available, :integer

    add_column :venue_dates, :date, :datetime
    add_column :venue_dates, :price_for_daytime, :integer
    add_column :venue_dates, :price_for_nighttime, :integer
    add_column :venue_dates, :is_available, :boolean, default: true
  end
end
