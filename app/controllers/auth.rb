# frozen_string_literal: true

require 'roda'
require_relative './app'

module CheckHigh
  # Web controller for CheckHigh API
  class App < Roda
    route('auth') do |routing|
      @login_route = '/auth/login'
      routing.is 'login' do
        # GET /auth/login
        routing.get do
          view :login
        end

        # POST /auth/login
        routing.post do
          # TODO: form login credentials
          credentials = Form::LoginCredentials.new.call(routing.params)

          if credentials.failure?
            flash[:error] = 'Please enter both username and password'
            routing.redirect @login_route
          end

          authenticated = AuthenticateAccount.new(App.config)
            .call(**credentials.values)

          current_account = Account.new(
            authenticated[:account],
            authenticated[:auth_token]
          )

          CurrentSession.new(session).current_account = current_account
          flash[:notice] = "Welcome back #{current_account.username}!"
          routing.redirect '/'
        rescue AuthenticateAccount::UnauthorizedError
          flash.now[:error] = 'Username and password did not match our records'
          response.status = 403
          view :login
        rescue AuthenticateAccount::ApiServerError => e
          puts "LOGIN ERROR: #{e.inspect}\n#{e.backtrace}"
          flash[:error] = 'Our servers are not responding -- please try later'
          response.status = 500
          routing.redirect @login_route
        end
      end

      # GET /auth/logout
      @logout_route = '/auth/logout'
      routing.on 'logout' do
        routing.get do
          CurrentSession.new(session).delete
          flash[:notice] = "You've been logged out"
          routing.redirect @login_route
        end
      end

      @register_route = '/auth/register'
      routing.on 'register' do
        routing.is do
          # GET /auth/register
          routing.get do
            view :register
          end

          # POST /auth/register
          routing.post do
            registration = Form::Registration.new.call(routing.params)

            if registration.failure?
              flash[:error] = Form.validation_errors(registration)
              routing.redirect @register_route
            end

            VerifyRegistration.new(App.config).call(registration.to_h)

            flash[:notice] = 'Please check your email for a verification link'
            routing.redirect '/'
          rescue StandardError => e
            puts "ERROR VERIFYING REGISTRATION: #{routing.params}\n#{e.inspect}"
            flash[:error] = 'Please use English characters for username only'
            routing.redirect @register_route
          end
        end

        # GET /auth/register/<token>
        routing.get(String) do |registration_token|
          # verify register token expire or not
          new_account = RegisterToken.payload(registration_token)
          flash.now[:notice] = 'Email Verified! Please choose a new password'
          view :register_confirm, locals: { new_account: new_account, registration_token: registration_token }
        rescue RegisterToken::ExpiredTokenError
          flash[:error] = 'The register token has expired, please register again.'
          response.status = 403
          routing.redirect @register_route
        end
      end
    end
  end
end
