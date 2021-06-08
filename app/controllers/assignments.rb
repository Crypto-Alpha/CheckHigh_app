# frozen_string_literal: true

require 'roda'
require_relative './app'

module CheckHigh
  # Web controller for CheckHigh API
  class App < Roda
    route('assignments') do |routing|
      routing.redirect '/auth/login' unless @current_account.logged_in?

      # GET /assignments/[assignment_id]
      routing.get(String) do |assignment_id|
        assignment = GetAssignmentDetail.new(App.config).call(@current_account, assignment_id)
        assignment_detail = AssignmentDetail.new(assignment)

        view :assignment,
          locals: { current_user: @current_account, assignment: assignment_detail }
      end
    end
  end
end
