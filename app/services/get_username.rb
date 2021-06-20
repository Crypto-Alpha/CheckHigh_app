# frozen_string_literal: true

require 'http'

module CheckHigh
  # Returns an authenticated user, or nil
  class GetUsername
    class NotFoundError < StandardError; end

    class ApiServerError < StandardError; end

    def call(email_data)
      credentials = { email: email_data['email'] }

      response = HTTP.post("#{ENV['API_URL']}/auth/username",
                           json: SignedMessage.sign(credentials))

      raise NotFoundError if response.code == 404
      raise ApiServerError if response.code != 200

      JSON.parse(response.to_s)['data']['attributes']
    end
  end
end
