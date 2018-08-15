class Token < ApplicationRecord
    belongs_to :user

    before_create do
		self.token = SecureRandom.hex + SecureRandom.hex 
    end
end
