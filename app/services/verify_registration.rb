# frozen_string_literal: true

require 'http'

module CheckHigh
  # Returns an authenticated user, or nil
  class VerifyRegistration
    class VerificationError < StandardError; end

    def initialize(config)
      @config = config
    end

    def call(registration_data)
      # register token will expire after an hour
      registration_token = VerifyToken.create(registration_data)

      registration_data['verification_url'] =
        "#{@config.APP_URL}/auth/register/#{registration_token}"

      response = HTTP.post("#{@config.API_URL}/auth/register",
                           json: SignedMessage.sign(registration_data))
      res = JSON.parse(response.to_s)
      raise(VerificationError, res['message']) unless response.code == 202
    end
  end
end
