# frozen_string_literal: true

require_relative 'assignment'

module CheckHigh
  # Behaviors of the currently logged in account
  class Assignments
    attr_reader :all

    def initialize(assignments_list)
      return @all = [] if assignments_list.length.zero?
      @all = assignments_list.map do |assi|
        Assignment.new(assi)
      end
    end
  end
end