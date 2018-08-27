class ReplyTemplateSerializer < ActiveModel::Serializer
  attributes :id, :subject, :message, :status
end