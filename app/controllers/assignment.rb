# frozen_string_literal: true

require 'roda'
require_relative './app'

module CheckHigh
  # Web controller for CheckHigh API
  class App < Roda
    route('assignment') do |routing|
      routing.on do
        # GET /assignment/[assignment_id]
        routing.get String do |assignment_id|
          if @current_account.logged_in?
            assignment = GetAssignmentDetail.new(App.config).call(@current_account, assignment_id)
            assignment_detail = AssignmentDetail.new(assignment)

            view :assignment,
            locals: { current_user: @current_account, assignment: assignment_detail }
          else
            routing.redirect '/auth/login'
          end
        end
      end
    end
  end
end
