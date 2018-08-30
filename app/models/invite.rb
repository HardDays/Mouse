class Invite < ApplicationRecord
  scope :venues, -> {where(invited_type: Invite.invited_types['venue'])}
  scope :artists, -> {where(invited_type: Invite.invited_types['artist'])}
  scope :fans, -> {where(invited_type: Invite.invited_types['fan'])}

  enum invited_type: [:artist, :venue, :fan]
end
