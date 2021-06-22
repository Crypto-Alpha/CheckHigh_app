# frozen_string_literal: true

require 'roda'
require_relative './app'

module CheckHigh
  # Web controller for CheckHigh API
  class App < Roda
    route('account') do |routing|
      routing.on do
        # GET /account/[username]
        routing.get String do |username|
          account = GetAccountDetails.new(App.config).call(
            @current_account, username
          )

          view :account, locals: { account: account }
        rescue GetAccountDetails::InvalidAccount => e
          flash[:error] = e.message
          routing.redirect '/auth/login'
        end

        # POST /account/<registration_token>
        routing.post String do |registration_token|
          passwords = Form::Passwords.new.call(routing.params)
          raise Form.message_values(passwords) if passwords.failure?

          new_account = VerifyToken.payload(registration_token)
          CreateAccount.new(App.config).call(
            email: new_account['email'],
            username: new_account['username'],
            password: passwords['password']
          )
          flash[:notice] = 'Account created! Please login'
          routing.redirect '/auth/login'
        rescue CreateAccount::InvalidAccount => e
          flash[:error] = e.message
          routing.redirect '/auth/register'
        rescue StandardError => e
          flash[:error] = e.message
          routing.redirect(
            "#{App.config.APP_URL}/auth/register/#{registration_token}"
          )
        end

        # POST /account/resetpwd/<resetpwd_token>
        routing.on 'resetpwd' do
          routing.post String do |resetpwd_token|
            passwords = Form::Passwords.new.call(routing.params)
            raise Form.message_values(passwords) if passwords.failure?

            resetpwd_account = VerifyToken.payload(resetpwd_token)

            ResetPwd.new(App.config).call(
              email: resetpwd_account['email'],
              password: passwords['password']
            )

            flash[:notice] = 'Account get back! Please login'
            routing.redirect '/auth/login'
          rescue ResetPwd::InvalidAccount => e
            flash[:error] = e.message
            routing.redirect '/auth/resetpwd'
          rescue StandardError => e
            flash[:error] = e.message
            routing.redirect(
              "#{App.config.APP_URL}/auth/resetpwd/#{resetpwd_token}"
            )
          end
        end

        # POST /account/invitation/<invitation_token>
        routing.on 'invitation' do
          routing.post String do |invitation_token|
            new_account = Form::InvitationRegistration.new.call(routing.params)
            raise Form.message_values(new_account) if new_account.failure?

            new_account_email = VerifyToken.payload(invitation_token)

            CreateAccount.new(App.config).call(
              email: new_account_email['email'],
              username: new_account['username'],
              password: new_account['password']
            )
            flash[:notice] = 'Account created! Please login'
            routing.redirect '/auth/login'
          rescue CreateAccount::InvalidAccount => e
            flash[:error] = e.message
            routing.redirect "/auth/register/#{invitation_token}"
          rescue StandardError => e
            flash[:error] = e.message
            routing.redirect(
              "#{App.config.APP_URL}/auth/register/#{invitation_token}"
            )
          end
        end
      end
    end
  end
end
