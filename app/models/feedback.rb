class Feedback < ApplicationRecord
  validates :feedback_type, presence: true
  validates_inclusion_of :rate_score, in: 1..5

  enum feedback_type: [:bug, :enhancement, :compliment]
end
