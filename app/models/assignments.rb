# frozen_string_literal: true

require_relative 'assignment'

module CheckHigh
  # Behaviors of the currently logged in account
  # It is use to show the assignments name and id (no content) (in Course)
  class Assignments
    attr_reader :all

    def initialize(assignments_list)
      @all = [] unless assignments_list.length

      @all = assignments_list.map do |assi|
        Assignment.new(assi)
      end
    end
  end
end
