class ChangeColumnIsCrowdfundingEventAtEvent < ActiveRecord::Migration[5.1]
  def change
    change_column :events, :is_crowdfunding_event, :boolean, default: true
  end
end
