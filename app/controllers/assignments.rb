# frozen_string_literal: true

require 'roda'
require_relative './app'

module CheckHigh
  # Web controller for CheckHigh API
  class App < Roda
    route('assignments') do |routing|
      routing.redirect '/auth/login' unless @current_account.logged_in?
      @courses_route = '/courses'

      # GET /assignments/[assignment_id]
      routing.get(String) do |assignment_id|
        assignment = GetAssignmentDetail.new(App.config).call(@current_account, assignment_id)
        assignment_detail = AssignmentDetail.new(assignment)

        view :assignment,
          locals: { current_user: @current_account, assignment: assignment_detail }
      end

      # POST /assignments
      routing.post do
        routing.redirect '/auth/login' unless @current_account.logged_in?
        puts "ASSIGNMENT: #{routing.params}"
        # TODO: form data
        assi_data = Form::NewAssignmentDetail.new.call(routing.params)
        if assi_data.failure?
          flash[:error] = Form.message_values(assi_data)
          routing.halt
        end

        CreateNewAssignment.new(App.config).call(
          current_account: @current_account,
          assi_data: assi_data.to_h
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
