# frozen_string_literal: true

require 'http'

# Move an assignment to a course
class MoveAssiToCourse
  def initialize(config)
    @config = config
  end

  def api_url
    @config.API_URL
  end

  def call(current_account, assignment_id, course_id)
    config_url = "#{api_url}/courses/#{course_id}/assignments/#{assignment_id}"
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .put(config_url)

    response.code == 200 ? JSON.parse(response.body.to_s) : raise
  end
end
