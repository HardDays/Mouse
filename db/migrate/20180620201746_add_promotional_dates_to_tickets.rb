class AddPromotionalDatesToTickets < ActiveRecord::Migration[5.1]
  def change
    add_column :tickets, :promotional_date_from, :datetime
    add_column :tickets, :promotional_date_to, :datetime
  end
end
