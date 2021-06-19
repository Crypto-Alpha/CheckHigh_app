# frozen_string_literal: true

require 'roda'
require_relative './app'

module CheckHigh
  # Web controller for CheckHigh API
  class App < Roda
    route('assignments') do |routing|
      routing.redirect '/auth/login' unless @current_account.logged_in?
        @home_route = '/'
        @assignments_route = '/assignments'
        @courses_route = '/courses'

      routing.on(String) do |assignment_id|
        @assignment_route = "#{@assignments_route}/#{assignment_id}"

        # POST /assignments/[assignment_id]/rename_assignment
        # form didn't enable put method
        routing.post('rename_assignment') do
          puts "ASSIGNMENT NEW NAME: #{routing.params}"
          redirect_route = routing.params['redirect_route']
          name_validation = Form::RenameRules.new.call(routing.params)
          if name_validation.failure?
            flash[:error] = Form.message_values(routing.params)
            routing.halt
          end

          new_name = { 'new_name' => routing.params['new_name'] }
          RenameAssignment.new(App.config).call(@current_account, assignment_id, new_name)

          flash[:notice] = "You've renamed an assignment"
        rescue StandardError => e
          puts "FAILURE Renaming Assignment: #{e.inspect}"
          flash[:error] = 'Could not rename a Assignment'
        ensure
          routing.redirect redirect_route
        end

        # POST /assignments/[assignment_id]/deletion
        # form didn't enable put method
        routing.post('deletion') do
          redirect_route = routing.params['redirect_route']
          RemoveAssignment.new(App.config).call(@current_account, assignment_id)

          flash[:notice] = "You've removed an assignment"
        rescue StandardError => e
          puts "FAILURE Removing a Lonely Assignment: #{e.inspect}"
          flash[:error] = 'Could not remove a Lonely Assignment'
        ensure
          routing.redirect redirect_route
        end

        # GET /assignments/[assignment_id]
        routing.get do
          assignment = GetAssignmentDetail.new(App.config).call(@current_account, assignment_id)
          assignment_detail = AssignmentDetail.new(assignment)

          courses_list = GetAllCourses.new(App.config).call(@current_account)
          share_board_list = GetAllShareBoards.new(App.config).call(@current_account)
          courses = Courses.new(courses_list)
          share_boards = ShareBoards.new(share_board_list)

          view :assignment, locals: {
            current_user: @current_account,
            assignment: assignment_detail,
            courses: courses,
            share_boards: share_boards
          }
        rescue StandardError => e
          puts "#{e.inspect}\n#{e.backtrace}"
          flash[:error] = 'Assignment not found'
          routing.redirect @home_route
        end
      end

      # POST /assignments
      routing.post do
        routing.redirect '/auth/login' unless @current_account.logged_in?
        puts "ASSIGNMENT: #{routing.params}"
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

        CreateNewAssignment.new(App.config).call(
          current_account: @current_account,
          assignment_data: assignment_details
        )

        flash[:notice] = 'Add new lonely assignments'
      rescue StandardError => e
        puts "FAILURE Creating Lonely Assignment: #{e.inspect}"
        flash[:error] = 'Could not create Lonely Assignment'
      ensure
        routing.redirect @courses_route
      end
    end
  end
end
