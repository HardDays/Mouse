class RenameTableCommentsToFeedComments < ActiveRecord::Migration[5.1]
  def change
    rename_table :comments, :feed_comments
  end
end
