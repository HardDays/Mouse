class SimpleFeedbackSerializer < ActiveModel::Serializer
  attributes :id, :feedback_type, :created_at, :rate_score, :sender

  # belongs_to :sender
  belongs_to :reply

  def feedback_type
    object.feedback_message.feedback_type
  end

  def rate_score
    object.feedback_message.rate_score
  end

  def sender
    object.sender.as_json(for_message: true)
  end
end