class EventCollaborator < ApplicationRecord
  belongs_to :event
  belongs_to :collaborator, class_name: 'Account'
end
