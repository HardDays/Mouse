class ChangeColumnFundingGoalAtEvents < ActiveRecord::Migration[5.1]
  def change
    change_column :events, :funding_goal, :integer, default: 0
  end
end
