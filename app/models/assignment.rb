# frozen_string_literal: true

require_relative 'account'
require_relative 'course'
require_relative 'share_board'

module CheckHigh
  # Behaviors of the currently logged in account
  # It is use to show the assignments name and id (no content) (in Course)
  class Assignment
    attr_reader :id, :assignment_name, :links, :upload_time, :owner_id, :owner_name, # basic info
                :owner, :course, :share_board, :policies # full details

    def initialize(assi_info)
      process_attributes(assi_info['attributes'])
      process_relationships(assi_info['relationships'])
      process_policies(assi_info['policies'])
    end

    private

    def process_attributes(attributes)
      @id = attributes['id']
      @assignment_name = attributes['assignment_name']
      @upload_time = attributes['upload_time']
      @owner_id = attributes['owner_id']
      @owner_name = attributes['owner_name']
    end

    def process_relationships(relationships)
      return unless relationships

      @owner = Account.new(relationships['owner'])
      @course = Course.new(relationships['course'])
      @share_board = ShareBoard.new(relationships['share_board'])
    end

    def process_policies(policies)
      @policies = OpenStruct.new(policies)
    end
  end
end
