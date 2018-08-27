class Admin < ApplicationRecord
  belongs_to :user
  belongs_to :image, optional: true

  has_many :processed_users, foreign_key: 'processed_by', class_name: 'Account', dependent: :nullify
  has_many :processed_events, foreign_key: 'processed_by', class_name: 'Event', dependent: :nullify
  has_many :send_messages, class_name: 'InboxMessage', dependent: :nullify

  def as_json(options={})
    res = super

    if options[:for_message]
      res[:image_id] = image_id
      res[:user_name] = user_name
      res[:account_type] = 'admin'
      res[:full_name] = "#{first_name} #{last_name}"
    end

    return res
  end
end
