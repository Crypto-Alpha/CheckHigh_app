# frozen_string_literal: true

require 'http'

# Rename a course
class RenameCourse
  def initialize(config)
    @config = config
  end

  def api_url
    @config.API_URL
  end

  def call(current_account, course_id, new_name)
    config_url = "#{api_url}/courses/#{course_id}"
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .put(config_url, json: new_name)

    response.code == 200 ? JSON.parse(response.body.to_s) : raise
  end
end
