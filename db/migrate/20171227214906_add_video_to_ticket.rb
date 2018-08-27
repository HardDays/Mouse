class AddVideoToTicket < ActiveRecord::Migration[5.1]
  def change
    add_column :tickets, :video, :string
  end
end
