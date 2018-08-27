require 'digest'
require 'securerandom'
require 'httparty'
require 'twitter'
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

class AuthenticateController < ApplicationController
	swagger_controller :auth, "Authentification"
	
	# POST /auth/forgot_password
	swagger_api :forgot_password do
		summary "Remind password"
		param :form, :user_name, :string, :optional, "Username"
		param :form, :email, :string, :optional, "Email"
		response :unauthorized
	end
	def forgot_password
		if params[:user_name]
			@account = Account.find_by("LOWER(user_name) = ?", params[:user_name].downcase)
			render status: :unauthorized and return if not @account
			@user = @account.user
		else
			@user = User.find_by("LOWER(email) = ?", params[:email].downcase)
			render status: :unauthorized and return if not @user
		end

		@attempt = ForgotPassAttempt.where(user_id: @user.id, created_at: (Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)).first
		if @attempt 
			render json: {error: :TOO_MANY_ATTEMPTS}, status: :bad_request and return if @attempt.attempt_count >= 3
			@attempt.attempt_count += 1
			@attempt.save
		else
			@attempt = ForgotPassAttempt.new(user_id: @user.id, attempt_count: 1)
			@attempt.save
		end

		password = SecureRandom.hex(4)
		@user.password = password
		begin
			ForgotPasswordMailer.forgot_password_email(params[:email], password).deliver 
			@user.save(validate: false)
			render status: :ok   
		rescue => ex
			render status: :bad_request
		end 
	end

	# POST /auth/request_code
	swagger_api :request_code do
		summary "Request sms code"
		param :form, :phone, :string, :required, "Phone	"
		response :unauthorized
	end
	def request_code
		account_sid = 'ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
		auth_token = 'yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy'

		@client = Twilio::REST::Client.new account_sid, auth_token

		max_min = 15
		max_att = 3

		@validation = PhoneValidation.find_by(phone: params[:phone])
		if @validation 
			cur_time = (Time.zone.now - @validation.updated_at) / 1.minutes
			if cur_time < max_min and @validation.attempts > max_att
				render json: {error: [:TOO_MANY_ATTEMPTS]}, status: :bad_request and return
			else
				if cur_time < max_min
					@validation.attempts += 1
				else
					@validation.attempts = 0
				end
				@validation.code = SecureRandom.hex(2)
			end
		else
			@validation = PhoneValidation.new(phone: params[:phone], code: SecureRandom.hex(2), attempts: 0)
		end	

		@validation.save

		@client.api.account.messages.create(
			from: '+14159341234',
			to: params[:phone],
			body: "Mouse code: #{@validation.code}"
		)

		render status: :ok
	end

	# POST /auth/login
	swagger_api :login do
		summary "Authorize by username and password"
		param :form, :user_name, :string, :optional, "Username"
		param :form, :email, :string, :optional, "Email"
		param :form, :password, :password, :required, "Password"
		response :unauthorized
	end
	def login
		@password = User.encrypt_password(params[:password])
		if params[:user_name]
			@account = Account.find_by("LOWER(user_name) = ?", params[:user_name].downcase)
			render status: :forbidden and return if not @account
			@user = @account.user
		else
			@user = User.find_by("LOWER(email) = ?", params[:email].downcase)
			render status: :forbidden and return if not @user
		end
		render status: :forbidden and return if @user.password != @password

		token = AuthenticateHelper.process_token(request, @user)
		render json: {token: token.token} , status: :ok

	end

	# POST /auth/login_vk
	swagger_api :login_vk do
		summary "Authorize by VK"
		param :form, :access_token, :string, :required, "Access token returned from VK"
		response :unauthorized
	end
	def login_vk
		uid = ""
		first_name = nil
		last_name = nil
		image_url = nil
		begin
			@vk = VkontakteApi::Client.new(params[:access_token])
			uid = @vk.users.get[0].id
			
			user = @vk.users.get(user_ids: uid, fields: [:photo_max_orig, :has_photo])
			
			first_name = user[0].first_name
			last_name = user[0].last_name
			if user[0].has_photo == 1
				image_url = user[0].photo_max_orig
			end
		rescue => ex
			render json: {"error_code": ex.error_code}, status: :unauthorized and return
		end

		@user = User.find_by(vk_id: uid)
		if not @user
			@user = User.new(vk_id: uid, first_name: first_name, last_name: last_name)

			image = ImagesHelper.download(image_url)
			if image
				@user.image_id = image.id
			end

			if not @user.save(validate: false)
				render status: :unauthorized and return
			end
		end

		token = AuthenticateHelper.process_token(request, @user)
		render json: {token: token.token} , status: :ok
	end

	# POST /auth/login_google
	swagger_api :login_google do
		summary "Authorize by google"
		param :form, :access_token, :string, :required, "Access token returned by authorization from google"
		response :unauthorized
	end
	def login_google
		response = HTTParty.get('https://www.googleapis.com/oauth2/v2/userinfo',
									headers: {Access_token: params['access_token'],
									Authorization: "OAuth #{params['access_token']}"})
		render status: :unauthorized and return if response.code != 200

		data = JSON.parse(response.body)

		@user = User.find_by(google_id: data['id'])
		if not @user
			@user = User.new(google_id: data['id'], first_name: data['given_name'], last_name: data['family_name']) 
			
			#downlad image
			image = ImagesHelper.download(data['picture'])
			if image
				@user.image_id = image.id
			end

			if not @user.save(validate: false)
				render status: :unauthorized and return
			end
		end

		token = AuthenticateHelper.process_token(request, @user)
		render json: {token: token.token} , status: :ok
	end

	# POST /auth/login_twitter
	swagger_api :login_twitter do
		summary "Authorize by twitter"
		param :form, :access_token, :string, :required, "Access token from twitter"
		param :form, :access_token_secret, :string, :required, "Access token secret from twitter"
		response :unauthorized
	end
	def login_twitter
		
		client = Twitter::REST::Client.new do |config|
			config.consumer_key        = 'TVm4kOpBBBjRwyCa9gAJ6SGzn'
			config.consumer_secret     = '7t6Yq20UCEBoJKTmwrNFMItoglFvCxWRQXx31LUqd7BO3dWGgY'
			config.access_token        = params[:access_token]
			config.access_token_secret = params[:access_token_secret]
		end
		@user = User.find_by(twitter_id: client.user.id)

		if not @user
			@user = User.new(twitter_id: client.user.id, first_name: client.user.name)
			#download photo
			if client.user.profile_image_uri?
				image = ImagesHelper.download(client.user.profile_image_uri(:original))
				if image
					@user.image_id = image.id
				end
			end

			if not @user.save(validate: false)
				render status: :unauthorized and return
			end
		end

		token = AuthenticateHelper.process_token(request, @user)
		render json: {token: token.token} , status: :ok
	end

	# POST /auth/login_facebook
	swagger_api :login_facebook do
		summary "Authorize by facebook"
		response :unauthorized
	end
	def login_facebook
		
	end

	# POST /auth/logout
	swagger_api :logout do
		summary "Logout"
		param :header, 'Authorization', :string, :required, 'Authentication token'
		response :bad_request
	end
	def logout
		@token = Token.find_by(token: request.headers['Authorization'])
		if @token
			@token.destroy
			render status: :ok
		end
	end
end
