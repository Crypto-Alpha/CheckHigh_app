# frozen_string_literal: true

require_relative 'assignment_detail'

module CheckHigh
  # Behaviors of the currently logged in account
  class AssignmentDetail
    attr_reader :id, :assignment_name, :links

    def initialize(assi_info)
      @id = assi_info['attributes']['id']
      @assignment_name = assi_info['attributes']['assignment_name']
      @links = assi_info['attributes']['links']['href']
    end
  end
end