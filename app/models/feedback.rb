class Feedback < ApplicationRecord
  validates :feedback_type, presence: true
  validates :rate_score, presence: true

  enum feedback_type: [:bug, :enhancement, :compliment]
end
