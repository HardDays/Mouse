class AdminMessage < ApplicationRecord
  validates_presence_of :message
  validates_presence_of :sender_id

  enum forwarder_type: [:account, :admin]

  belongs_to :admin_topic, foreign_key: 'topic_id'
  belongs_to :sender, foreign_key: 'sender_id', class_name: 'Admin'
end