# frozen_string_literal: true

require 'http'

# Returns all assignments belonging to an Course
class GetAllAssignments
  def initialize(config)
    @config = config
  end

  def call(current_account, course_id)
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .get("#{@config.API_URL}/courses/#{course_id}/assignments")

    response.code == 200 ? JSON.parse(response.to_s)['data'] : nil
  end
end
