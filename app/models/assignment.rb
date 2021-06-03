# frozen_string_literal: true

require_relative 'assignment'

module CheckHigh
  # Behaviors of the currently logged in account
  class Assignment
    attr_reader :id, :assignment_name, :links

    def initialize(assi_info)
      # TODO_0603: due to the simplify_to_json problem, it catches the another data structure
      @id = assi_info['attributes']['id']
      @assignment_name = assi_info['attributes']['assignment_name']
      @content = assi_info['attributes']['content']
      # @links = assi_info['attributes']['links']['href']
    end
  end
end
