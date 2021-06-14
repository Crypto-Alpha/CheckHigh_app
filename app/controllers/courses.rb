# frozen_string_literal: true

require 'roda'
require_relative './app'

module CheckHigh
  # Web controller for CheckHigh API
  class App < Roda
    route('courses') do |routing|      
      routing.on do
        routing.redirect '/auth/login' unless @current_account.logged_in?
        @courses_route = '/courses'

        routing.on(String) do |course_id|
          @course_route = "#{@courses_route}/#{course_id}" 

          # GET /courses/[course_id]
          routing.get do
            crs_details = GetCourseDetail.new(App.config).call(@current_account, course_id)
            crs = Course.new(crs_details)

            view :course, locals: { current_user: @current_account, course: crs }
          rescue StandardError => e
            puts "#{e.inspect}\n#{e.backtrace}"
            flash[:error] = 'Course not found'
            routing.redirect @courses_route
          end

          # POST /courses/[course_id]/assignments/
          routing.post('assignments') do
            params = routing.params['file']
            assignment_data = Form::NewAssignmentDetail.new.call(params)
            if assignment_data.failure?
              flash[:error] = Form.message_values(assignment_data)
              routing.halt
            end

            # read the content out
            assignment_details = {
              assignment_name: assignment_data[:filename],
              content: assignment_data[:tempfile].read.force_encoding('UTF-8')
            }

            CreateNewAssignment.new(App.config).call_for_course(
              current_account: @current_account,
              course_id: course_id,
              assignment_data: assignment_details
            )

            flash[:notice] = 'Your assignment was added'
          rescue StandardError => e
            puts e.inspect
            puts e.backtrace
            flash[:error] = 'Could not add assignment'
          ensure
            routing.redirect @course_route
          end
        end

        # GET /courses
        routing.get do
          courses_list = GetAllCourses.new(App.config).call(@current_account)
          not_belong_assignments_list = GetNotBelongAssignments.new(App.config).call(@current_account)
          courses = Courses.new(courses_list)
          not_belong_assi = Assignments.new(not_belong_assignments_list)

          view :courses, locals: { current_user: @current_account, courses: courses, assignments: not_belong_assi }
        end

        # POST /courses
        routing.post do
          routing.redirect '/auth/login' unless @current_account.logged_in?
          puts "COURSE: #{routing.params}"
          # TODO: form data
          course_data = Form::NewCourse.new.call(routing.params)
          if course_data.failure?
            flash[:error] = Form.message_values(course_data)
            routing.halt
          end

          CreateNewCourse.new(App.config).call(
            current_account: @current_account,
            course_data: course_data.to_h
          )

          flash[:notice] = 'Add a new course'
        rescue StandardError => e
          puts "FAILURE Creating Course: #{e.inspect}"
          flash[:error] = 'Could not create course'
        ensure
          routing.redirect @courses_route
        end
      end
    end
  end
end
