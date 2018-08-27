class RemovePhoneFromVenue < ActiveRecord::Migration[5.1]
  def change
    remove_column :venues, :phone, :string
  end
end
