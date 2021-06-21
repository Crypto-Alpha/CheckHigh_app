# frozen_string_literal: true

require 'http'

module CheckHigh
  # Returns an authenticated user, or nil
  class VerifyResetPwd
    class VerificationError < StandardError; end

    def initialize(config)
      @config = config
    end

    def call(resetpwd_data)
      # register token will expire after an hour
      resetpwd_token = VerifyToken.create(resetpwd_data)

      resetpwd_data['verification_url'] =
        "#{@config.APP_URL}/auth/resetpwd/#{resetpwd_token}"

      response = HTTP.post("#{@config.API_URL}/auth/resetpwd",
                           json: SignedMessage.sign(resetpwd_data))
      raise(VerificationError) unless response.code == 202

      JSON.parse(response.to_s)
    end
  end
end
