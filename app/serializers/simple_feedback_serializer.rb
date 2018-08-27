class SimpleFeedbackSerializer < ActiveModel::Serializer
  attributes :id, :feedback_type, :created_at, :rate_score

  belongs_to :account
end