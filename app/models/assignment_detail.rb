# frozen_string_literal: true

require_relative 'account'
require_relative 'course'
require_relative 'share_board'

module CheckHigh
  # Behaviors of the currently logged in account
  # It is use to show the assignments name, id and content (in ShareBoard & Assignment itself)
  class AssignmentDetail
    attr_reader :id, :assignment_name, :upload_time,
                :content,
                :owner, :course, :share_board, :policies # full details

    def initialize(assi_info)
      process_attributes(assi_info['attributes'])
      process_relationships(assi_info['relationships'])
      process_policies(assi_info['policies'])
      # process_included(info['include'])
    end

    private

    def process_attributes(attributes)
      @id = attributes['id']
      @assignment_name = attributes['assignment_name']
      @upload_time = attributes['upload_time']
      @content = attributes['content']
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

    # def process_included(included)
    #   @share_board = ShareBoard.new(included['share_board'])
    # end
  end
end
