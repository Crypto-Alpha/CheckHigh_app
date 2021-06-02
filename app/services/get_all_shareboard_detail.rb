# frozen_string_literal: true

require 'http'

# Returns all share boards belonging to an account
class GetAllShareBoardDetail
  def initialize(config)
    @config = config
  end

  def call(current_account, id)
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .get("#{@config.API_URL}/share_boards/#{id}/assignments")

    response.code == 200 ? JSON.parse(response.to_s)['data'] : nil
  end
end