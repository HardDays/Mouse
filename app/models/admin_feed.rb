class AdminFeed < ApplicationRecord
  validates_presence_of :action
  validates_presence_of :value

  enum action: [:new_admin, :new_bug, :new_users]

  def save
    ApplicationCable::AdminNotificationsChannel.broadcast_to(user_id, new: true)
    super
  end

  def as_json(options)
    if options[:only]
      super(options)
    else
      if action == "new_admin"
        res[:admin] = Admin.find(value).only(:user_name, :first_name, :last_name, :image_id)
      elsif action == "new_bug"
        res[:message] = InboxMessage.find(value)
      end
    end
  end
end
