class User < ApplicationRecord

	validates :email, presence: true, uniqueness: true
	validates :register_phone, uniqueness: true, allow_nil: true
	validates :password, length: {:within => 6..100}, :allow_blank => true #, confirmation: true

	enum preferred_language: [:en, :ru]
	enum preferred_distance: [:mi, :km]
	enum preferred_currency: [:USD, :RUB, :EUR]

	before_save :encrypt, if: :password_changed?
	validates_confirmation_of :password, message: 'NOT_MATCHED'
	attr_accessor :password_confirmation
	
	validate :check_old, if: :password_changed?, on: :update
	attr_accessor :old_password

	has_many :tokens, dependent: :destroy
	has_many :accounts, dependent: :destroy
	has_many :likes, dependent: :nullify

	belongs_to :image, optional: true
	has_one :admin, dependent: :destroy

    SALT = 'elite_salt'
    
	def self.encrypt_password(password)
		return Digest::SHA256.hexdigest(password + SALT)
	end

	def encrypt 
		self.password = User.encrypt_password(self.password) if self.password
	end

	def check_old
		if self.old_password != nil
			errors.add(:old_password, 'NOT_MACHED') if User.find(id).password != User.encrypt_password(self.old_password)
		end
	end

	def has_access?(access_name)
		@access = self.accesses.find{|a| a.name == access_name.to_s}
		return @access != nil ? true : false
	end

	def as_json(options={})
		if options[:preferences]
			attrs = {}
			attrs[:preferred_username] = preferred_username
			attrs[:preferred_date] = preferred_date
			attrs[:preferred_distance] = preferred_distance
			attrs[:preferred_currency] = preferred_currency
			attrs[:preferred_time] = preferred_time
			return attrs
		end

		return super(options)
	end
end
