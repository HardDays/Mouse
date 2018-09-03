class AdminTopic < ApplicationRecord
  validates_presence_of :sender_id
  validates_presence_of :receiver_id
  validates_uniqueness_of :receiver_id, scope: [:sender_id]
  validates_presence_of :topic

  enum topic_type: [:message, :bug]

  belongs_to :sender, foreign_key: 'sender_id', class_name: 'Admin'
  belongs_to :receiver, foreign_key: 'receiver_id', class_name: 'Admin'

  has_many :admin_messages, foreign_key: 'topic_id', dependent: :destroy
end