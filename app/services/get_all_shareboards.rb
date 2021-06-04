# frozen_string_literal: true

require 'http'

# Returns all share boards belonging to an account
class GetAllShareBoards
  def initialize(config)
    @config = config
  end

  def call(current_account)
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .get("#{@config.API_URL}/share_boards")
    response.code == 200 ? JSON.parse(response.to_s)['data'] : nil
  end
end
