class AdminAccountSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :account_type, :display_name, :status,
             :address, :first_name, :last_name, :processed_by, :image_id

  def address
    if object.account_type == 'artist' and object.artist
      return object.artist.preferred_address
    elsif object.account_type == 'fan' and object.fan
      return object.fan.address
    elsif object.account_type == 'venue' and object.venue
      return object.venue.address
    end
  end

  def first_name
    object.user.first_name
  end

  def last_name
    object.user.last_name
  end

  def processed_by
    if object.admin
      object.admin.user_name
    else
      nil
    end
  end
end
