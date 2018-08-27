class AdminEventsAnalyticSerializer < ActiveModel::Serializer
  attributes :name, :date_from, :is_crowdfunding_event, :comments, :likes, :views, :status
end