class AdminEventRevenueSerializer < ActiveModel::Serializer
  attributes :id, :name, :owner, :date_from, :is_crowdfunding_event, :address,
             :total_revenue, :artist_revenue, :venue_revenue, :vr_revenue, :tickets_revenue, :advertising_revenue

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

  def artist_revenue
    object.artist_events.joins(:agreed_date_time_and_price).where(
      status: 'owner_accepted').sum('agreed_date_time_and_prices.price')
  end

  def venue_revenue
    object.venue_events.joins(:agreed_date_time_and_price).where(
      status: 'owner_accepted').sum('agreed_date_time_and_prices.price')
  end

  def tickets_revenue
    object.tickets.left_joins(:fan_tickets, :tickets_type).where(
      tickets: {tickets_types: {name: 'in_person'}, is_promotional: false}
    ).sum('fan_tickets.price')
  end

  def vr_revenue
    object.tickets.left_joins(:fan_tickets, :tickets_type).where(
      tickets: {tickets_types: {name: 'vr'}, is_promotional: false}
    ).sum('fan_tickets.price')
  end

  def advertising_revenue
    object.tickets.left_joins(:fan_tickets).where(
      tickets: {is_promotional: true}
    ).sum('fan_tickets.price')
  end
end