# frozen_string_literal: true

require_relative 'assignment'

module CheckHigh
  # Behaviors of the currently logged in account
  class AssignmentsDetails
    attr_reader :all

    def initialize(assignments_list)
      @all = assignments_list.map do |assi|
        Assignment.new(assi)
      end
    end
  end
end