# frozen_string_literal: true

require_relative 'course'

module CheckHigh
  # Behaviors of the currently logged in account
  class Courses
    attr_reader :all

    def initialize(courses_list)
      return @all = [] if courses_list.length.zero?
      @all = courses_list.map do |course|
        Course.new(course)
      end
    end
  end
end