# frozen_string_literal: true

require_relative 'course'

module CheckHigh
  # Behaviors of the currently logged in account
  # It is use to show the assignments name and id (no content) (in Course)
  class Assignment
    attr_reader :id, :assignment_name, :links, :upload_time, # basic info
                :course # full details

    def initialize(info)
      process_attributes(info['attributes'])
      process_included(info['include'])
    end

    private

    def process_attributes(attributes)
      @id = attributes['id']
      @assignment_name = attributes['assignment_name']
      @upload_time = attributes['upload_time']
    end

    def process_included(included)
      @course = Course.new(included['course'])
    end
  end
end
