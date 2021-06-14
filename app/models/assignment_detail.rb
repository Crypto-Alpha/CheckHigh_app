# frozen_string_literal: true

require_relative 'account'
require_relative 'course'
require_relative 'share_board'

module CheckHigh
  # Behaviors of the currently logged in account
  # It is use to show the assignments name, id and content (in ShareBoard & Assignment itself)
  class AssignmentDetail
    attr_reader :id, :assignment_name, :upload_time, # basic info
                :content, :owner, # assignment info
                :course, :share_boards, :policies # full details

    def initialize(assi_info)
      process_attributes(assi_info['attributes'])
      process_included(assi_info['include'])
      process_relationships(assi_info['relationships'])
      process_policies(assi_info['policies'])
    end

    private

    def process_attributes(attributes)
      @id = attributes['id']
      @assignment_name = attributes['assignment_name']
      @upload_time = attributes['upload_time']
      @content = attributes['content']
    end

    def process_included(included)
      @owner = Account.new(included['owner'])
    end

    def process_relationships(relationships)
      return unless relationships

      @course = Course.new(relationships['course']) if relationships['course']
      @share_boards = process_share_boards(relationships['share_boards'])
    end

    def process_share_boards(share_boards_info)
      return nil unless share_boards_info

      share_boards_info.map { |srb_info| ShareBoard.new(srb_info) }
    end

    def process_policies(policies)
      @policies = OpenStruct.new(policies)
    end
  end
end
