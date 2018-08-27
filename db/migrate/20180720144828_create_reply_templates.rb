class CreateReplyTemplates < ActiveRecord::Migration[5.1]
  def change
    create_table :reply_templates do |t|
      t.string :subject
      t.string :message
      t.integer :status

      t.timestamps
    end
  end
end
