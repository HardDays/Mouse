class Feedback < ApplicationRecord
  validates :feedback_type, presence: true
  validates :rate_score, presence: true

  enum feedback_type: [:bug, :enhancement, :compliment]

  belongs_to :account
  belongs_to :reply, foreign_key: 'message_id', class_name: 'InboxMessage', optional: true
end
