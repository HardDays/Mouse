class AdminTopic < ApplicationRecord
  validates_presence_of :sender_id
  validates_presence_of :receiver_id
  validates_presence_of :topic

  enum topic_type: [:message, :bug]

  belongs_to :sender, foreign_key: 'sender_id', class_name: 'Admin'
  belongs_to :receiver, foreign_key: 'receiver_id', class_name: 'Admin'

  has_many :admin_messages, foreign_key: 'topic_id', dependent: :destroy

  def as_json(options={})
    if options[:only]
      super(options)
    else
      res = super

      if sender_id == options[:my_id]
        res[:with] = receiver.as_json(only: [:image_id, :user_name, :first_name, :last_name])
      elsif receiver_id == options[:my_id]
        res[:with] = sender.as_json(only: [:image_id, :user_name, :first_name, :last_name])
      end

      res[:is_forwarded] = false
      if admin_messages.where.not(forwarded_from: nil).exists?
        res[:is_forwarded] = true
      end

      if options[:my_id]
        res[:is_read] = !admin_messages.where(is_read: false).where.not(sender_id: options[:my_id]).exists?
      end

      res
    end
  end

  def self.search(text)
    @topics = AdminTopic.all
    if text
      @topics = @topics.where(
        "topic ILIKE :query", query: "%#{sanitize_sql_like(text)}%"
      )
    end

    return @topics
  end
end