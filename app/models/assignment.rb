# frozen_string_literal: true

require_relative 'assignment'

module CheckHigh
  # Behaviors of the currently logged in account
  # It is use to show the assignments name and id (no content) (in Course)
  class Assignment
    attr_reader :id, :assignment_name, :links, :upload_time

    def initialize(assi_info)
      @id = assi_info['attributes']['id']
      @assignment_name = assi_info['attributes']['assignment_name']
      @upload_time = assi_info['attributes']['upload_time']
    end
  end
end
