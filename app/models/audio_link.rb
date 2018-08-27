class AudioLink < ApplicationRecord
  validates :audio_link, presence: true
  validates :song_name, presence: true
  validates :album_name, presence: true

  belongs_to :artist
end
