# frozen_string_literal: true

require 'roda'
require_relative './app'

module CheckHigh
  # Web controller for CheckHigh API
  class App < Roda
    # TODO_0605: not sure how to write the next route path eg. share_boards/[id]/check
    route('share_board') do |routing|
      routing.on do
        # GET /share_board/[share_board_id]
        routing.get String do |share_board_id|
          if @current_account.logged_in?
            srb_assi_list = GetAllAssignments.new(App.config).call(@current_account, "share_boards", share_board_id)
            srb_assi = AssignmentsDetail.new(srb_assi_list)
            view :share_board_check, locals: { current_user: @current_account, assignments: srb_assi }
          else
            routing.redirect '/auth/login'
          end
        end
      end
    end

    route('share_boards') do |routing|
      routing.on do
        # GET /share_boards/[share_board_id]
        routing.get String do |share_board_id|
          if @current_account.logged_in?
            srb_assi_list = GetAllAssignments.new(App.config).call(@current_account, "share_boards", share_board_id)
            srb_assi = Assignments.new(srb_assi_list)
            
            view :share_board, locals: { current_user: @current_account, assignments: srb_assi }
          else
            routing.redirect '/auth/login'
          end
        end
        # GET /share_boards
        routing.get do
          if @current_account.logged_in?
            shareboard_list = GetAllShareBoards.new(App.config).call(@current_account)

            shareboards = ShareBoards.new(shareboard_list)

            view :share_boards, locals: { current_user: @current_account, share_boards: shareboards }
          else
            routing.redirect '/auth/login'
          end
        end
      end
    end
  end
end
