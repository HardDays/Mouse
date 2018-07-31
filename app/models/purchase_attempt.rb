class PurchaseAttempt < ApplicationRecord
    enum status: [:pending, :finished, :canceled]
    enum purchase_type: [:fan_ticket]
    enum platform: [:yandex, :paypal]

    belongs_to :account
end
