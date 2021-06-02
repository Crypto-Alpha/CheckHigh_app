# frozen_string_literal: true

require 'roda'
require_relative './app'

module CheckHigh
  # Web controller for CheckHigh API
  class App < Roda
    # route('course') do |routing|
    #   routing.on do
    #     # GET /course
    #     routing.get do
    #       if @current_account.logged_in?
    #         course_list = GetAllCourseDetail.new(App.config).call(@current_account, id)

    #         courses = Courses.new(course_list)

    #         view :course,
    #         locals: { current_user: @current_account, course: courses }
    #       else
    #         routing.redirect '/auth/login'
    #       end
    #     end
    #   end
    # end

    route('course') do |routing|
      routing.on do
        # GET /course
        routing.get do
          view :course
        end
      end
    end

    route('courses') do |routing|
      routing.on do
        # GET /courses
        routing.get do
          if @current_account.logged_in?
            course_list = GetAllCourse.new(App.config).call(@current_account)

            courses = Courses.new(course_list)

            view :courses,
            locals: { current_user: @current_account, courses: courses }
          else
            routing.redirect '/auth/login'
          end
        end
      end
    end
  end
end
