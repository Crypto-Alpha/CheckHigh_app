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

          routing.is do
            # GET /courses/[course_id]
            routing.get do
              crs_details = GetCourseDetail.new(App.config).call(@current_account, course_id)
              crs = Course.new(crs_details)

              courses_list = GetAllCourses.new(App.config).call(@current_account)
              share_board_list = GetAllShareBoards.new(App.config).call(@current_account)
              courses = Courses.new(courses_list)
              share_boards = ShareBoards.new(share_board_list) 

              view :course, locals: { current_user: @current_account, course: crs, courses: courses, share_boards: share_boards }
            rescue StandardError => e
              puts "#{e.inspect}\n#{e.backtrace}"
              flash[:error] = 'Course not found'
              routing.redirect @courses_route
            end

            # POST /courses/[course_id]
            routing.post do
              puts "COURSE NEW NAME: #{routing.params}"
              redirect_route = routing.params['redirect_route']
              name_validation = Form::RenameRules.new.call(routing.params)
              if name_validation.failure?
                flash[:error] = Form.message_values(routing.params)
                routing.halt
              end

              new_name = { "new_name" => routing.params['new_name'] }
              RenameCourse.new(App.config).call(@current_account, course_id, new_name)

              flash[:notice] = "You've renamed a course"
            rescue StandardError => e
              puts "#{e.inspect}\n#{e.backtrace}"
              flash[:error] = 'Could not rename a course'
            ensure
              routing.redirect redirect_route
            end
          end

          # POST /courses/[course_id]/deletion
          # remove a course
          routing.on('deletion') do
            routing.post do
              redirect_route = routing.params["redirect_route"]
              RemoveCourse.new(App.config).call(@current_account, course_id)

              flash[:notice] = "You've removed a course"
            rescue StandardError => e
              puts "FAILURE Removing a course: #{e.inspect}"
              flash[:error] = 'Could not remove a course'
            ensure
              routing.redirect redirect_route
            end
          end

          routing.on('assignments') do
            routing.on(String) do |assignment_id|
              # POST /courses/[course_id]/assignments/[assignment_id]/move_course
              routing.post('move_course') do
                redirect_route = routing.params["redirect_route"]
                MoveAssiToCourse.new(App.config).call(@current_account, assignment_id, course_id)
                flash[:notice] = "You've moved your assignment to new course."
              rescue StandardError => e
                puts "FAILURE Moving an assignment to a new course: #{e.inspect}"
                flash[:error] = 'Could not move an assignment to new course'
              ensure
                routing.redirect redirect_route
              end

              # POST /courses/[course_id]/assignments/[assignment_id]/move_lonely_assignment
              # remove assignment from this course
              routing.post('move_lonely_assignment') do
                redirect_route = routing.params["redirect_route"]
                RemoveAssiFromCourse.new(App.config).call(@current_account, assignment_id, course_id)
                flash[:notice] = "You've removed your assignment from this course."
              rescue StandardError => e
                puts "FAILURE Moving an assignment to lonely assingments: #{e.inspect}"
                flash[:error] = 'Could not move an assignment to lonely assignments'
              ensure
                routing.redirect redirect_route
              end
            end

            # POST /courses/[course_id]/assignments/
            routing.post do 
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
              puts "ERROR CREATING ASSIGNMENT: #{e.inspect}"
              flash[:error] = 'Could not add assignment'
            ensure
              routing.redirect @course_route
            end
          end
        end

        # GET /courses
        routing.get do
          courses_list = GetAllCourses.new(App.config).call(@current_account)
          share_board_list = GetAllShareBoards.new(App.config).call(@current_account) 
          not_belong_assignments_list = GetNotBelongAssignments.new(App.config).call(@current_account)
          courses = Courses.new(courses_list)
          not_belong_assi = Assignments.new(not_belong_assignments_list)
          share_boards = ShareBoards.new(share_board_list) 

          view :courses, locals: { current_user: @current_account, courses: courses, assignments: not_belong_assi, share_boards: share_boards }
        end

        # POST /courses
        routing.post do
          routing.redirect '/auth/login' unless @current_account.logged_in?
          puts "COURSE: #{routing.params}"
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
