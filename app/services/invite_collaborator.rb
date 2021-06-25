# frozen_string_literal: true

require 'http'

module CheckHigh
  # Service to remove collaborator to shareboard
  class InviteCollaborator
    class CollaboratorNotInvited < StandardError; end

    def initialize(config)
      @config = config
    end

    def api_url
      @config.API_URL
    end

    def invitation(current_account, collaborator)
      invitation_data = collaborator.to_h.merge(inviter: current_account.account_info['attributes']['username'])
      invitation_token = VerifyToken.create(invitation_data)
      invitation_data['verification_url'] = "#{@config.APP_URL}/auth/register/#{invitation_token}"
      invitation_data
    end

    def call(current_account:, collaborator:, share_board_id:)
      invitation_data = invitation(current_account, collaborator)
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .post("#{api_url}/share_boards/#{share_board_id}/collaborators",
                           json: SignedMessage.sign(invitation_data))

      res = JSON.parse(response.to_s)
      raise(CollaboratorNotInvited, res['message']) unless response.code == 202
    end
  end
end
