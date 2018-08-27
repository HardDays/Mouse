class AddVrCapacityToVenue < ActiveRecord::Migration[5.1]
  def change
    add_column :venues, :vr_capacity, :integer, default: 200
  end
end
