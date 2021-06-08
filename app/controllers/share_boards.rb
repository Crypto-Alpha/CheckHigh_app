# frozen_string_literal: true

require 'roda'
require_relative './app'

module CheckHigh
  # Web controller for CheckHigh API
  class App < Roda
    route('share_boards') do |routing|
      routing.on do
        routing.redirect '/auth/login' unless @current_account.logged_in?
        @share_boards_route = '/share_boards'

        routing.on(String) do |share_board_id|
          @share_board_route = "#{@share_boards_route}/#{share_board_id}"

          # GET /share_boards/[share_board_id]
          routing.get do
            srb_assi_list = GetAllAssignments.new(App.config).call(@current_account, "share_boards", share_board_id)
            srb_assi = AssignmentsDetail.new(srb_assi_list)
            view :share_board, locals: { current_user: @current_account, assignments: srb_assi }

          rescue StandardError => e
            puts "#{e.inspect}\n#{e.backtrace}"
            flash[:error] = 'ShareBoard not found'
            routing.redirect @share_boards_route
          end

          # TODO_0605: not sure how to write the next route path eg. share_boards/[id]/check
          # Not sure if it will work or not...
          # GET /share_boards/[share_board_id]/check
          routing.post('check') do
            # 應該要透過上一頁的check_high button送assignment資料到check頁面然後秀出來
            srb_assi = routing.params['check_high']
            view :share_board_check, locals: { current_user: @current_account, assignments: srb_assi }

          rescue StandardError => e
            puts "#{e.inspect}\n#{e.backtrace}"
            flash[:error] = 'Cannot check your assignments!'
            routing.redirect @share_boards_route
          end

          # POST /share_boards/[share_board_id]/collaborators
          routing.post('collaborators') do
            action = routing.params['action']
            #TODO: form data

            task_list = {
              'add' => { service: AddCollaborator,
                         message: 'Added new collaborator to share_board' },
              'remove' => { service: RemoveCollaborator,
                            message: 'Removed collaborator from share_board' }
            }

            task = task_list[action]
            task[:service].new(App.config).call(
              current_account: @current_account,
              collaborator: collaborator_info,
              share_board_id: share_board_id
            )
            flash[:notice] = task[:message]
          rescue StandardError
            flash[:error] = 'Could not find collaborator'
          ensure
            routing.redirect @share_board_route
          end

          # POST /share_boards/[share_board_id]/assignments/
          routing.post('assignments') do
            # TODO: form data
            
            CreateNewAssignment.new(App.config).call_for_shareboard(
              current_account: @current_account,
              share_board_id: share_board_id,
              assignment_data: assignment_data.to_h
            )

            flash[:notice] = 'Your assignment was added'
          rescue StandardError => error
            puts error.inspect
            puts error.backtrace
            flash[:error] = 'Could not add assignment'
          ensure
            routing.redirect @share_board_route
          end
        end

        # GET /share_boards
        routing.get do
          shareboard_list = GetAllShareBoards.new(App.config).call(@current_account)

          shareboards = ShareBoards.new(shareboard_list)

          view :share_boards, locals: { current_user: @current_account, share_boards: shareboards }
        end

        # POST /share_boards
        routing.post do 
          routing.redirect '/auth/login' unless @current_account.logged_in?
          puts "SHAREBOARD: #{routing.params}"
          # TODO: form data

          CreateNewShareBoard.new(App.config).call(
            current_account: @current_account,
            share_board_data: share_board_data.to_h
          )

          flash[:notice] = 'Add assignments and collaborators to your new share board'
        rescue StandardError => e
          puts "FAILURE Creating share board: #{e.inspect}"
          flash[:error] = 'Could not create share board'
        ensure
          routing.redirect @share_boards_route
        end
      end
    end
  end
end
