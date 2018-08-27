class AddAdditionalCostsToEvent < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :additional_cost, :integer
  end
end
