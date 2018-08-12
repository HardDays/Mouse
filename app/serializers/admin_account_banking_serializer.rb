class AdminAccountBankingSerializer < ActiveModel::Serializer
  attributes :id, :account_type, :user_name, :status, :address, :full_name, :banking

  def address
    if object.account_type == 'artist' and object.artist
      return object.artist.preferred_address
    elsif object.account_type == 'fan' and object.fan
      return object.fan.address
    elsif object.account_type == 'venue' and object.venue
      return object.venue.address
    end
  end

  def full_name
    if object.account_type == 'fan' and object.fan
      return "#{object.fan.first_name} #{object.fan.last_name}"
    else
      return object.display_name
    end
  end

  def banking
    ''
  end
end