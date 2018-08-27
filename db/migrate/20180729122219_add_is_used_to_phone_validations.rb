class AddIsUsedToPhoneValidations < ActiveRecord::Migration[5.1]
  def change
    add_column :phone_validations, :is_used, :boolean
  end
end
