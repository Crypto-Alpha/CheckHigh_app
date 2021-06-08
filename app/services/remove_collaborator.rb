# frozen_string_literal: true

# Service to remove collaborator to project
class RemoveCollaborator
  class CollaboratorNotRemoved < StandardError; end

  def initialize(config)
    @config = config
  end

  def api_url
    @config.API_URL
  end

  def call(current_account:, collaborator:, share_board_id:)
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .delete("#{api_url}/share_boards/#{share_board_id}/collaborators",
                           json: { email: collaborator[:email] })

    raise CollaboratorNotRemoved unless response.code == 200
  end
end
