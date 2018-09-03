class AdminMessage < ApplicationRecord
  validates_presence_of :message
  validates_presence_of :sender_id

  enum forwarder_type: [:account, :admin]

  belongs_to :admin_topic, foreign_key: 'topic_id'
  belongs_to :sender, foreign_key: 'sender_id', class_name: 'Admin'

  def as_json(options={})
    res = super

    if forwarder_type == 'account'
      res.delete('forwarder_type')
      res['forwarded_from'] = Account.where(id: forwarded_from.to_i).first.as_json(only: :user_name)
    elsif forwarder_type == 'admin'
      res.delete('forwarder_type')
      res['forwarded_from'] = Admin.where(id: forwarded_from.to_i).first.as_json(only: [:first_name, :last_name])
    end

    return res
  end
end