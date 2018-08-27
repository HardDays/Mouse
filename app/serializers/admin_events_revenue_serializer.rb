class AdminEventsRevenueSerializer < ActiveModel::Serializer
  attributes :id, :name, :owner, :date_from, :is_crowdfunding_event, :address, :revenue

  def owner
    if object.creator
      if object.creator.fan
        return "#{object.creator.fan.first_name} #{object.creator.fan.last_name}"
      elsif object.creator.artist
        return "#{object.creator.artist.first_name} #{object.creator.artist.last_name}"
      elsif object.creator.venue
        return object.creator.display_name
      end
    else
      nil
    end
  end
end