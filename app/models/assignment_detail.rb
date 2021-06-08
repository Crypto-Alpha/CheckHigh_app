# frozen_string_literal: true

require_relative 'share_board'

module CheckHigh
  # Behaviors of the currently logged in account
  # It is use to show the assignments name, id and content (in ShareBoard & Assignment itself)
  class AssignmentDetail
    attr_reader :id, :assignment_name, :upload_time,
                :content,
                :share_board # full details

    def initialize(info)
      process_attributes(info['attributes'])
      process_included(info['include'])
    end

    private

    def process_attributes(attributes)
      @id = attributes['id']
      @assignment_name = attributes['assignment_name']
      @upload_time = attributes['upload_time']
      @content = attributes['content']
    end

    def process_included(included)
      @share_board = ShareBoard.new(included['share_board'])
    end
  end
end
