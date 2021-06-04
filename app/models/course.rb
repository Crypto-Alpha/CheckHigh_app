# frozen_string_literal: true

require_relative 'course'

module CheckHigh
  # Behaviors of the currently logged in account
  class Course
    attr_reader :id, :course_name, :links

    def initialize(course_info)
      @id = course_info['attributes']['id']
      @course_name = course_info['attributes']['course_name']
      @links = course_info['attributes']['links']['href']
    end
  end
end