class AdminAccountBankingSerializer < ActiveModel::Serializer
  attributes :id, :account_type, :user_name, :status, :address, :first_name, :last_name, :banking

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

  def banking
    ''
  end
end