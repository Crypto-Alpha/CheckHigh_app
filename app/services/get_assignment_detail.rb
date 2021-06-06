# frozen_string_literal: true

require 'http'

# Returns all assignments belonging to an account
class GetAssignmentDetail
  def initialize(config)
    @config = config
  end

  def call(current_account, assignment_id)
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .get("#{@config.API_URL}/assignments/#{assignment_id}")
    response.code == 200 ? JSON.parse(response.to_s)['data'] : nil
  end
end
