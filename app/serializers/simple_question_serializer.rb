class SimpleQuestionSerializer < ActiveModel::Serializer
  attributes :id, :subject

  belongs_to :account
end