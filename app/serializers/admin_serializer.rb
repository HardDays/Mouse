class AdminSerializer < ActiveModel::Serializer
  attributes :id, :image_id, :first_name, :last_name, :user_name, :email, :register_phone,
             :address, :address_other, :city, :country, :state

  def email
    object.user.email
  end

  def register_phone
    object.user.register_phone
  end
end