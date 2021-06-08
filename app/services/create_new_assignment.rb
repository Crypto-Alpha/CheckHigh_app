# frozen_string_literal: true

require 'http'

# Create a new assignment for a course or share_board
class CreateNewAssignment
  def initialize(config)
    @config = config
  end

  def api_url
    @config.API_URL
  end

  def call_for_course(current_account:, course_id:, assigment_data:)
    config_url = "#{api_url}/courses/#{course_id}/assignments"
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .post(config_url, json: assignment_data)

    response.code == 201 ? JSON.parse(response.body.to_s) : raise
  end

  def call_for_shareboard(current_account:, share_board_id:, assigment_data:)
    config_url = "#{api_url}/share_boards/#{share_board_id}/assignments"
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .post(config_url, json: assignment_data)

    response.code == 201 ? JSON.parse(response.body.to_s) : raise
  end
end
