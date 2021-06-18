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
      # register token will expire after 5 minutes
      registration_token = RegisterToken.create(registration_data)
      
      registration_data['verification_url'] = 
        "#{@config.APP_URL}/auth/register/#{registration_token}"

      response = HTTP.post("#{@config.API_URL}/auth/register",
                           json: registration_data)
      puts response
      raise(VerificationError) unless response.code == 202

      JSON.parse(response.to_s)
    end
  end
end
