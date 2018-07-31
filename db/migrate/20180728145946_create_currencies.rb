class CreateCurrencies < ActiveRecord::Migration[5.1]
  def change
    create_table :currencies do |t|
      t.integer :num_code
      t.string :char_code
      t.integer :nominal
      t.string :name
      t.float :value

      t.timestamps
    end
  end
end
