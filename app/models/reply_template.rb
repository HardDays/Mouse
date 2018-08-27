class ReplyTemplate < ApplicationRecord
  enum status: [:added, :approved]
end
