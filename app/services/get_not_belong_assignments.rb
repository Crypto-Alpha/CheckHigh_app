# frozen_string_literal: true

require 'http'

# Returns all assignments belonging to an account but not belonging to any courses
class GetNotBelongAssignments
  def initialize(config)
    @config = config
  end

  def call(current_account)
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .get("#{@config.API_URL}/assignments")

    response.code == 200 ? JSON.parse(response.to_s)['data'] : nil
  end
end
