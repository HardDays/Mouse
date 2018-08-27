class AdminEventSerializer < ActiveModel::Serializer
  attributes :id, :name, :date_from, :address, :status, :is_crowdfunding_event, :received_date, :processed_by

  def received_date
    object.created_at
  end

  def processed_by
    if object.admin
      object.admin.user_name
    else
      nil
    end
  end
end
