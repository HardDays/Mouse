class EventUpdate < ApplicationRecord
    enum action: HistoryHelper::EVENT_ACTIONS, _suffix: true
    enum field: HistoryHelper::EVENT_FIELDS, _suffix: true

    belongs_to :event

    def as_json(options={})
        res = super
        if options[:feed]
            res[:event] = event.as_json(only: [:id, :name])
            res[:account] = event.creator.as_json(:only => [:id, :user_name, :image_id])
            res[:comments] = event.comments.count
            res[:likes] = event.likes.count
            res[:is_liked] = event.likes.where(user_id: options[:user].id).exists?

            res.delete('user_id')
            res.delete('event_id')
            res.delete('updated_at')
            res.delete('updated_by')
            res.delete('id')
        end
        return res
    end
end
