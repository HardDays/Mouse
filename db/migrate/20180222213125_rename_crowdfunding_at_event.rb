class RenameCrowdfundingAtEvent < ActiveRecord::Migration[5.1]
  def change
     rename_column :events, :crowdfunding_event, :is_crowdfunding_event
  end
end
