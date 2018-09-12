class LogHelper
  def self.log_account_changed_value(field, account, value)
    if account.status == "approved"
      feed = FeedItem.new(
        action: :update,
        updated_by: account.id,
        account_id: account.id,
        field: field,
        value: value
      )
      feed.save
    end
  end
end