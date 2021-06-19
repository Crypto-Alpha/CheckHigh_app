# frozen_string_literal: true

require_relative 'account'
require_relative 'assignment'

module CheckHigh
  # Behaviors of the currently logged in account
  class ShareBoard
    attr_reader :id, :share_board_name, :links, # basic info
                :owner, :collaborators, :assignments, :policies # full details

    def initialize(share_board_info)
      process_attributes(share_board_info['attributes'])
      process_relationships(share_board_info['relationships'])
      process_policies(share_board_info['policies'])
    end

    private

    def process_attributes(attributes)
      @id = attributes['id']
      @share_board_name = attributes['share_board_name']
      @links = attributes['links']['href']
    end

    def process_relationships(relationships)
      return unless relationships

      @owner = Account.new(relationships['owner'])
      @collaborators = process_collaborators(relationships['collaborators'])
      @assignments = process_assignments(relationships['assignments'])
    end

    def process_policies(policies)
      @policies = OpenStruct.new(policies)
    end

    def process_assignments(assignments_info)
      return nil unless assignments_info

      assignments_info.map { |assi_info| Assignment.new(assi_info) }
    end

    def process_collaborators(collaborators)
      return nil unless collaborators

      collaborators.map { |account_info| Account.new(account_info) }
    end
  end
end
