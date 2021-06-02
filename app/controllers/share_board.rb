# frozen_string_literal: true

require 'roda'
require_relative './app'

module CheckHigh
  # Web controller for CheckHigh API
  class App < Roda
    # route('share_board') do |routing|
    #   routing.on do
    #     # GET /share_board
    #     routing.get do
    #       if @current_account.logged_in?
    #         shareboard_list = GetAllShareBoardDetail.new(App.config).call(@current_account, id)

    #         shareboards = ShareBoards.new(shareboard_list)

    #         view :share_board,
    #         locals: { current_user: @current_account, share_board: shareboards }
    #       else
    #         routing.redirect '/auth/login'
    #       end
    #     end
    #   end
    # end

    route('share_board') do |routing|
      routing.on do
        # GET /share_board
        routing.get do
          view :share_board
        end
      end
    end

    route('share_boards') do |routing|
      routing.on do
        # GET /share_boards
        routing.get do
          if @current_account.logged_in?
            shareboard_list = GetAllShareBoard.new(App.config).call(@current_account)

            shareboards = ShareBoards.new(shareboard_list)

            view :share_boards,
            locals: { current_user: @current_account, share_boards: shareboards }
          else
            routing.redirect '/auth/login'
          end
        end
      end
    end
  end
end
