class AddPromotionalDescriptionToTickets < ActiveRecord::Migration[5.1]
  def change
    add_column :tickets, :promotional_description, :string
  end
end
