# frozen_string_literal: true

require_relative 'assignment_detail'

module CheckHigh
  # Behaviors of the currently logged in account
  class AssignmentsDetails
    attr_reader :all

    def initialize(assignments_list)
      @all = assignments_list.map do |assi|
        AssignmentDetail.new(assi)
      end
    end
  end
end