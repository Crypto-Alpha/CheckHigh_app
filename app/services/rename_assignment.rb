# frozen_string_literal: true

require 'http'

# Rename an assignment 
class RenameAssignment
  def initialize(config)
    @config = config
  end

  def api_url
    @config.API_URL
  end

  def call(current_account, assignment_id, new_name)
    config_url = "#{api_url}/assignments/#{assignment_id}"
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .put(config_url, json: new_name)

    response.code == 200 ? JSON.parse(response.body.to_s) : raise
  end
end
