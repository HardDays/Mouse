class AddIsForwarderToFeedback < ActiveRecord::Migration[5.1]
  def change
    add_column :feedbacks, :is_forwarded, :boolean, default: false
  end
end
