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

  def call_content(current_account, assignment_id)
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .get("#{@config.API_URL}/assignments/#{assignment_id}/assignment_content")
    response.code == 200 ? response : nil
  end
end
