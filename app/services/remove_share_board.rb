# frozen_string_literal: true

require 'http'

# Remove a share_board 
class RemoveShareBoard
  def initialize(config)
    @config = config
  end

  def api_url
    @config.API_URL
  end

  def call(current_account, share_board_id)
    config_url = "#{api_url}/share_boards/#{share_board_id}"
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .delete(config_url)

    response.code == 200 ? JSON.parse(response.body.to_s) : raise
  end
end
