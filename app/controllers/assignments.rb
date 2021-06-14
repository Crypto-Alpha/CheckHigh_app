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

        # GET /assignments/[assignment_id]
        routing.get do
          assignment = GetAssignmentDetail.new(App.config).call(@current_account, assignment_id)
          assignment_detail = AssignmentDetail.new(assignment)

          view :assignment, locals: { current_user: @current_account, assignment: assignment_detail }
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
          flash[:error] = Form.message_values(assi_data)
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
