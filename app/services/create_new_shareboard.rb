# frozen_string_literal: true

require 'http'

# Create a new shareboard
class CreateNewShareBoard
  def initialize(config)
    @config = config
  end

  def api_url
    @config.API_URL
  end

  def call(current_account:, share_board_data:)
    config_url = "#{api_url}/share_boards"
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .post(config_url, json: share_board_data)

    response.code == 201 ? JSON.parse(response.body.to_s) : raise
  end
end
