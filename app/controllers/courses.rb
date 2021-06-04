# frozen_string_literal: true

require 'roda'
require_relative './app'

module CheckHigh
  # Web controller for CheckHigh API
  class App < Roda
    route('courses') do |routing|      
      routing.on do
        # GET /courses/[course_id]
        routing.get String do |course_id|
          if @current_account.logged_in?
            course_assi_list = GetAllAssignments.new(App.config).call(@current_account, course_id)
            course_assi = Assignments.new(course_assi_list)
            
            view :course, locals: { current_user: @current_account, assignments: course_assi }
          else
            routing.redirect '/auth/login'
          end
        end

        # GET /courses
        routing.get do
          if @current_account.logged_in?
            courses_list = GetAllCourses.new(App.config).call(@current_account)
            not_belong_assignments_list = GetNotBelongAssignments.new(App.config).call(@current_account)
            courses = Courses.new(courses_list)
            not_belong_assi = Assignments.new(not_belong_assignments_list)

            view :courses, locals: { current_user: @current_account, courses: courses, assignments: not_belong_assi }
          else
            routing.redirect '/auth/login'
          end
        end
      end
    end
  end
end
