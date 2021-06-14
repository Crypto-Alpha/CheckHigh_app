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

          # GET /share_boards/[share_board_id]/check
          routing.on('check') do
            srb_assi_list = GetAllAssignments.new(App.config).call(@current_account, "share_boards", share_board_id)
            srb_assi = AssignmentsDetail.new(srb_assi_list)

            view :share_board_check, locals: { current_user: @current_account, assignments: srb_assi }
          rescue StandardError => e
            puts "#{e.inspect}\n#{e.backtrace}"
            flash[:error] = 'Cannot check your assignments!'
            routing.redirect @share_boards_route
          end

          # GET /share_boards/[share_board_id]
          routing.get do
            srb_details = GetShareBoardDetail.new(App.config).call(@current_account, share_board_id)
            srb = ShareBoard.new(srb_details)

            view :share_board, locals: { current_user: @current_account, share_board: srb }
          rescue StandardError => e
            puts "#{e.inspect}\n#{e.backtrace}"
            flash[:error] = 'ShareBoard not found'
            routing.redirect @share_boards_route
          end

          # POST /share_boards/[share_board_id]/collaborators
          routing.post('collaborators') do
            action = routing.params['action']

            collaborator_info = Form::CollaboratorEmail.new.call(routing.params)
            if collaborator_info.failure?
              flash[:error] = Form.validation_errors(collaborator_info)
              routing.halt
            end

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

            CreateNewAssignment.new(App.config).call_for_shareboard(
              current_account: @current_account,
              share_board_id: share_board_id,
              assignment_data: assignment_details
            )

            flash[:notice] = 'Your assignment was added'
          rescue StandardError => e
            puts e.inspect
            puts e.backtrace
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
          share_board_data = Form::NewShareBoard.new.call(routing.params)
          if share_board_data.failure?
            flash[:error] = Form.message_values(share_board_data)
            routing.halt
          end
          CreateNewShareBoard.new(App.config).call(
            current_account: @current_account,
            share_board_data: share_board_data.to_h
          )

          flash[:notice] = 'Add a new share board'
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
