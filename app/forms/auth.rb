# frozen_string_literal: true

require_relative 'form_base'

module CheckHigh
  module Form
    # login form
    class LoginCredentials < Dry::Validation::Contract
      params do
        required(:email).filled(format?: EMAIL_REGEX)
        required(:password).filled
      end
    end

    # registration form
    class Registration < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/account_details.yml')

      params do
        required(:username).filled(format?: USERNAME_REGEX, min_size?: 4)
        required(:email).filled(format?: EMAIL_REGEX)
      end
    end

    # invitation registration form
    class InvitationRegistration < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/invitation_details.yml')

      params do
        required(:username).filled(format?: USERNAME_REGEX, min_size?: 4)
        required(:password).filled
        required(:password_confirm).filled
      end
    end

    # reset pwd form
    class ResetPwd < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/reset_details.yml')

      params do
        required(:email).filled(format?: EMAIL_REGEX)
      end
    end

    # password form
    class Passwords < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/password.yml')

      params do
        required(:password).filled
        required(:password_confirm).filled
      end

      def enough_entropy?(string)
        StringSecurity.entropy(string) >= 3.0
      end

      rule(:password) do
        key.failure('Password must be more complex') unless enough_entropy?(value)
      end

      rule(:password, :password_confirm) do
        key.failure('Passwords do not match') unless values[:password].eql?(values[:password_confirm])
      end
    end
  end
end
