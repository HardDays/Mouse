class Admin < ApplicationRecord
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :user_name, presence: true

  belongs_to :user
  belongs_to :image, optional: true

  has_many :processed_users, foreign_key: 'processed_by', class_name: 'Account', dependent: :nullify
  has_many :processed_events, foreign_key: 'processed_by', class_name: 'Event', dependent: :nullify
  has_many :send_messages, class_name: 'InboxMessage', dependent: :nullify
  has_many :send_topics, foreign_key: 'sender_id', class_name: 'AdminTopic', dependent: :nullify
  has_many :received_topics, foreign_key: 'receiver_id', class_name: 'AdminTopic', dependent: :nullify
  has_many :send_messages, foreign_key: 'sender_id', class_name: 'AdminMessage', dependent: :nullify

  def as_json(options={})
    res = super

    if options[:for_message]
      attrs = {}
      attrs[:image_id] = image_id
      attrs[:user_name] = user_name
      attrs[:account_type] = 'admin'
      attrs[:full_name] = "#{first_name} #{last_name}"
      attrs[:address] = address

      return attrs
    end

    return res
  end
end
