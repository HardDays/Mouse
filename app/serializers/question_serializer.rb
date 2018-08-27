class QuestionSerializer < ActiveModel::Serializer
  attributes :id, :subject, :message

  belongs_to :account
  belongs_to :question_reply
end