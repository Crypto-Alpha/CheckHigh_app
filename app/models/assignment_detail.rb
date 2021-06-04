# frozen_string_literal: true

require_relative 'assignment_detail'

module CheckHigh
  # Behaviors of the currently logged in account
  # It is use to show the assignments name, id and content (in ShareBoard)
  class AssignmentDetail
    attr_reader :id, :assignment_name, :content

    def initialize(assi_info)
      @id = assi_info['attributes']['id']
      @assignment_name = assi_info['attributes']['assignment_name']
      @content = assi_info['attributes']['content']
    end
  end
end
