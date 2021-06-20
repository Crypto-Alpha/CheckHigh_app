# frozen_string_literal: true

require 'roda'
require_relative './app'

module CheckHigh
  # Web controller for CheckHigh App
  # rubocop:disable Matrics/ClassLength
  class App < Roda
    def gh_oauth_url(config)
      url = config.GH_OAUTH_URL
      client_id = config.GH_CLIENT_ID
      scope = config.GH_SCOPE

      "#{url}?client_id=#{client_id}&scope=#{scope}"
    end

    def google_oauth_url(config, call_back_uri)
      url = config.GOOGLE_OAUTH_URL
      client_id = config.GOOGLE_CLIENT_ID
      scope = config.GOOGLE_SCOPE 

      "#{url}?client_id=#{client_id}&scope=#{scope}&response_type=code&access_type=offline&include_granted_scopes=true&redirect_uri=#{call_back_uri}"
    end

    route('auth') do |routing|
      @oauth_callback = '/auth/sso_callback'
      @google_callback_uri = "#{App.config.APP_URL}/auth/google_sso_callback"
      @login_route = '/auth/login'
      routing.is 'login' do
        # GET /auth/login
        routing.get do
          view :login, locals: { gh_oauth_url: gh_oauth_url(App.config) , google_oauth_url: google_oauth_url(App.config, @google_callback_uri) }
        end

        # POST /auth/login
        routing.post do
          credentials = Form::LoginCredentials.new.call(routing.params)

          if credentials.failure?
            flash[:error] = 'Please enter both username and password'
            routing.redirect @login_route
          end

          authenticated = AuthenticateAccount.new.call(**credentials.values)

          current_account = Account.new(
            authenticated[:account],
            authenticated[:auth_token]
          )

          CurrentSession.new(session).current_account = current_account

          flash[:notice] = "Welcome back #{current_account.username}!"
          routing.redirect '/'
        rescue AuthenticateAccount::NotAuthenticatedError
          flash[:error] = 'Username and password did not match our records'
          response.status = 401
          routing.redirect @login_route
        rescue StandardError => e
          puts "LOGIN ERROR: #{e.inspect}\n#{e.backtrace}"
          flash[:error] = 'Our servers are not responding -- please try later'
          response.status = 500
          routing.redirect @login_route
        end
      end

      routing.is 'sso_callback' do
        # GET /auth/sso_callback
        routing.get do
          authorized = AuthorizeGithubAccount
                       .new(App.config)
                       .call(routing.params['code'])

          current_account = Account.new(
            authorized[:account],
            authorized[:auth_token]
          )

          CurrentSession.new(session).current_account = current_account

          flash[:notice] = "Welcome #{current_account.username}!"
          routing.redirect '/'
        rescue AuthorizeGithubAccount::UnauthorizedError
          flash[:error] = 'Could not login with Github. Please check your GitHub public email.'
          response.status = 403
          routing.redirect @login_route
        rescue StandardError => e
          puts "SSO LOGIN ERROR: #{e.inspect}\n#{e.backtrace}"
          flash[:error] = 'Unexpected API Error'
          response.status = 500
          routing.redirect @login_route
        end
      end

      # GET google oauth
      routing.is 'google_sso_callback' do
        # GET /auth/google_sso_callback
        routing.get do
          authorized = AuthorizeGoogleAccount
                       .new(App.config)
                       .call(@google_callback_uri, routing.params['code'])

          current_account = Account.new(
            authorized[:account],
            authorized[:auth_token]
          )

          CurrentSession.new(session).current_account = current_account

          flash[:notice] = "Welcome #{current_account.username}!"
          routing.redirect '/'
        rescue AuthorizeGoogleAccount::UnauthorizedError
          flash[:error] = 'Could not login with Google.'
          response.status = 403
          routing.redirect @login_route
        rescue StandardError => e
          puts "GOOGLE SSO LOGIN ERROR: #{e.inspect}\n#{e.backtrace}"
          flash[:error] = 'Unexpected API Error'
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
            view :register, locals: { gh_oauth_url: gh_oauth_url(App.config) }
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
          new_account = VerifyToken.payload(registration_token)
          action_route = "/account/#{registration_token}"

          flash.now[:notice] = 'Email Verified! Please choose a new password'
          view :account_confirm, locals: { account: new_account,
                                           action_route: action_route }
        rescue VerifyToken::ExpiredTokenError
          flash[:error] = 'The register token has expired, please register again.'
          response.status = 403
          routing.redirect @register_route
        end

        @resetpwd_route = '/auth/resetpwd'
        routing.on 'resetpwd' do
          routing.is do
            # GET /auth/resetpwd
            routing.get do
              view :resetpwd
            end
  
            # POST /auth/resetpwd
            routing.post do
              resetpwd = Form::ResetPwd.new.call(routing.params)
  
              if resetpwd.failure?
                flash[:error] = Form.validation_errors(resetpwd)
                routing.redirect @resetpwd_route
              end
  
              VerifyResetPwd.new(App.config).call(resetpwd.to_h)
  
              flash[:notice] = 'Please check your email for a verification link'
              routing.redirect '/'
            rescue StandardError => e
              puts "ERROR VERIFYING RESET PWD: #{routing.params}\n#{e.inspect}"
              flash[:error] = 'Please use a valid email address'
              routing.redirect @resetpwd_route
            end
          end
  
          # GET /auth/resetpwd/<token>
          routing.get(String) do |resetpwd_token|
            # verify reset token expire or not and get the account email
            email = VerifyToken.payload(resetpwd_token)
  
            # TODO: get username or not
            # get the account username
            username = GetUsername.new.call(email)
            account = email.merge(username)
  
            # route to post the pwd
            action_route = "/account/resetpwd/#{resetpwd_token}"
  
            flash.now[:notice] = 'Email Verified! Please choose a new password'
            view :account_confirm, locals: { account: account,
                                             action_route: action_route }
          rescue VerifyToken::ExpiredTokenError
            flash[:error] = 'The reset password token has expired, please try again.'
            response.status = 403
            routing.redirect @resetpwd_route
          end
        end  
      end
    end
  end
  # rubocop:enable Matrics/ClassLength
end
