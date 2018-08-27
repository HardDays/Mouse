class AddExpirationDateToRequestMessages < ActiveRecord::Migration[5.1]
  def change
    add_column :request_messages, :expiration_date, :datetime
  end
end
