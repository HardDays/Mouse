class Question < ApplicationRecord
  belongs_to :account
  belongs_to :question_reply, foreign_key: 'message_id', class_name: 'InboxMessage', optional: true
end
