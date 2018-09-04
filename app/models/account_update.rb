class AccountUpdate < ApplicationRecord
    enum action: HistoryHelper::ACCOUNT_ACTIONS, _suffix: true
    enum field: HistoryHelper::ACCOUNT_FIELDS, _suffix: true

    belongs_to :account
end
