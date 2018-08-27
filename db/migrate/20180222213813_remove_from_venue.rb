class RemoveFromVenue < ActiveRecord::Migration[5.1]
  def change
    remove_column :venues, :fax, :string
    remove_column :venues, :bank_name, :string
    remove_column :venues, :account_bank_number, :string
    remove_column :venues, :account_bank_routing_number, :string
    remove_column :venues, :num_of_bathrooms, :integer
    remove_column :venues, :min_age, :integer
    remove_column :venues, :has_bar, :boolean
    remove_column :venues, :located, :integer
    remove_column :venues, :dress_code, :string
    remove_column :venues, :audio_description, :string
    remove_column :venues, :lighting_description, :string
    remove_column :venues, :stage_description, :string
  end
end
