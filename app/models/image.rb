class Image < ApplicationRecord
    belongs_to :account, optional: true
    belongs_to :event, optional: true

    has_one :owner_account, foreign_key: 'image_id', class_name: 'Account', dependent: :nullify
    has_one :image_type, dependent: :destroy

    def as_json(options={})
        res = super

        if options[:image_only]
            res.delete('base64')
        end

        res[:type] = image_type ? image_type.image_type : ''
        res[:type_decs] = image_type ? image_type.description : ''
        return res
    end
end
