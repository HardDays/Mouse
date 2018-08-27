class RenameTimeFrameAtRequestMessages < ActiveRecord::Migration[5.1]
  def change
    add_column :request_messages, :time_frame_range, :integer, default: 0
    add_column :request_messages, :time_frame_number, :integer, default: 0
  end
end
