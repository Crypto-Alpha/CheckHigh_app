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

  def call_for_course(current_account:, course_id:, assignment_data:)
    config_url = "#{api_url}/courses/#{course_id}/assignments"
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .headers(content_type: 'text/plain; charset=us-ascii',
                            assignment_name: assignment_data[:assignment_name])
                   .post(config_url, body: assignment_data[:content])

    response.code == 201 ? JSON.parse(response.body.to_s) : raise
  end

  def call_for_shareboard(current_account:, share_board_id:, assignment_data:)
    config_url = "#{api_url}/share_boards/#{share_board_id}/assignments"
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .headers(content_type: 'text/plain; charset=us-ascii',
                            assignment_name: assignment_data[:assignment_name])
                   .post(config_url, body: assignment_data[:content])

    response.code == 201 ? JSON.parse(response.body.to_s) : raise
  end

  def call(current_account:, assignment_data:)
    config_url = "#{api_url}/assignments"
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .headers(content_type: 'text/plain; charset=us-ascii',
                            assignment_name: assignment_data[:assignment_name])
                   .post(config_url, body: assignment_data[:content])

    response.code == 201 ? JSON.parse(response.body.to_s) : raise
  end

  def add_exist_assi_to_shareboard(current_account:, share_board_id:, assignment_id:)
    config_url = "#{api_url}/share_boards/#{share_board_id}/assignments/#{assignment_id}"
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .post(config_url)

    response.code == 201 ? JSON.parse(response.body.to_s) : raise
  end
end
