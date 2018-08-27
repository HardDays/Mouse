class AddTicketsTypesToEvent < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :has_vr, :boolean, default: false
    add_column :events, :has_in_person, :boolean, default: false
  end
end
