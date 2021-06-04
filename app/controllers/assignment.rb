# frozen_string_literal: true

require 'roda'
require_relative './app'

module CheckHigh
  # Web controller for CheckHigh API
  class App < Roda
    # route('assignment') do |routing|
    #   routing.on do
    #     # GET /assignment
    #     routing.get do
    #       if @current_account.logged_in?
    #         assignment_list = GetAllAssignmentsDetail.new(App.config).call(@current_account, id)

    #         assignment_details = AssignmentsDetails.new(assignment_list)

    #         view :assignment,
    #         locals: { current_user: @current_account, assignment: assignment_details }
    #       else
    #         routing.redirect '/auth/login'
    #       end
    #     end
    #   end
    # end
    route('assignment') do |routing|
      routing.on do
        # GET /assignment
        routing.get do
          view :assignment
        end
      end
    end

    route('assignments') do |routing|
      routing.on do
        # GET /assignments
        routing.get do
          if @current_account.logged_in?
            assignment_list = GetAllAssignments.new(App.config).call(@current_account)

            assignments = Assignments.new(assignment_list)

            view :assignments, locals: { current_user: @current_account, assignments: assignments }
          else
            routing.redirect '/auth/login'
          end
        end
      end
    end
  end
end
