class PhoneValidation < ApplicationRecord
    validates :phone, uniqueness: true, allow_nil: true
end
