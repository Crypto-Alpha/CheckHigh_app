# frozen_string_literal: true

require 'http'

# Returns all assignments belonging to an Course
class GetAllAssignments
  def initialize(config)
    @config = config
  end

  # get_type: course_assi, srb_assi
  def call(current_account, get_type, id)
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .get("#{@config.API_URL}/#{get_type}/#{id}/assignments")

    response.code == 200 ? JSON.parse(response.to_s)['data'] : nil
  end
end
