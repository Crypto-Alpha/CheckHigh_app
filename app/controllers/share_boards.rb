# frozen_string_literal: true

require 'roda'
require_relative './app'

module CheckHigh
  # Web controller for CheckHigh API
  # rubocop:disable Metrics/ClassLength
  class App < Roda
    route('share_boards') do |routing|
      routing.on do
        routing.redirect '/auth/login' unless @current_account.logged_in?
        @share_boards_route = '/share_boards'

        routing.on(String) do |share_board_id|
          @share_board_route = "#{@share_boards_route}/#{share_board_id}"

          routing.is do
            # GET /share_boards/[share_board_id]
            routing.get do
              srb_details = GetShareBoardDetail.new(App.config).call(@current_account, share_board_id)
              srb = ShareBoard.new(srb_details)

              courses_list = GetAllCourses.new(App.config).call(@current_account)
              share_board_list = GetAllShareBoards.new(App.config).call(@current_account)
              courses = Courses.new(courses_list)
              share_boards = ShareBoards.new(share_board_list)

              view :share_board, locals: { current_user: @current_account,
                                           share_board: srb,
                                           share_boards: share_boards,
                                           courses: courses }
            rescue StandardError => e
              puts "#{e.inspect}\n#{e.backtrace}"
              flash[:error] = 'ShareBoard not found'
              routing.redirect @share_boards_route
            end

            # POST /share_boards/[share_board_id]
            routing.post do
              puts "SHARE BOARD NEW NAME: #{routing.params}"
              redirect_route = routing.params['redirect_route']
              name_validation = Form::RenameRules.new.call(routing.params)
              if name_validation.failure?
                flash[:error] = Form.message_values(routing.params)
                routing.halt
              end

              new_name = { 'new_name' => routing.params['new_name'] }
              RenameShareBoard.new(App.config).call(@current_account, share_board_id, new_name)

              flash[:notice] = "You've renamed a share board"
            rescue StandardError => e
              puts "#{e.inspect}\n#{e.backtrace}"
              flash[:error] = 'Could not rename a share board'
            ensure
              routing.redirect redirect_route
            end
          end

          # GET /share_boards/[share_board_id]/check
          routing.on('check') do
            srb_assi_list = GetAllAssignments.new(App.config).call(@current_account, 'share_boards', share_board_id)
            srb_assi = AssignmentsDetail.new(srb_assi_list)

            view :share_board_check, locals: { current_user: @current_account, assignments: srb_assi }
          rescue StandardError => e
            puts "#{e.inspect}\n#{e.backtrace}"
            flash[:error] = 'Cannot check your assignments!'
            routing.redirect @share_boards_route
          end

          # POST /share_boards/[share_board_id]/deletion
          # remove a share board
          routing.on('deletion') do
            routing.post do
              redirect_route = routing.params['redirect_route']
              RemoveShareBoard.new(App.config).call(@current_account, share_board_id)

              flash[:notice] = "You've removed a shrae board"
            rescue StandardError => e
              puts "FAILURE Removing a share board: #{e.inspect}"
              flash[:error] = 'Could not remove a share board'
            ensure
              routing.redirect redirect_route
            end
          end

          routing.on('collaborators') do
            # POST /share_boards/[share_board_id]/collaborators
            routing.post do
              action = routing.params['action']
              redirect_route = routing.params['redirect_route']
              msg = routing.params['msg']

              collaborator_info = Form::CollaboratorEmail.new.call(routing.params)
              if collaborator_info.failure?
                flash[:error] = Form.validation_errors(collaborator_info)
                routing.halt
              end

              task_list = {
                'add' => { service: AddCollaborator,
                           message: 'Added new collaborator to shareboard',
                           reroute: @share_board_route },
                'remove' => { service: RemoveCollaborator,
                              message: msg,
                              reroute: redirect_route },
                'invite' => { service: InviteCollaborator,
                              message: 'Invitation Email Sent',
                              reroute: @share_board_route }
              }

              task = task_list[action]
              task[:service].new(App.config).call(
                current_account: @current_account,
                collaborator: collaborator_info,
                share_board_id: share_board_id
              )
              flash[:notice] = task[:message]
            rescue InviteCollaborator::CollaboratorNotInvited
              flash[:error] = 'You might invite an user already registered in CheckHigh.'
            rescue StandardError
              flash[:error] = 'Could not find collaborator. You can send an invitation email.'
            ensure
              routing.redirect task[:reroute]
            end
          end

          routing.on('assignments') do
            # POST /share_boards/[share_board_id]/assignments
            routing.post do
              params = routing.params['file']
              assignment_data = Form::NewAssignmentDetail.new.call(params)
              if assignment_data.failure?
                flash[:error] = Form.message_values(assignment_data)
                routing.halt
              end

              assignment_details = ExtractContent.new(assignment_data).extract

              CreateNewAssignment.new(App.config).call_for_shareboard(
                current_account: @current_account,
                share_board_id: share_board_id,
                assignment_data: assignment_details
              )

              flash[:notice] = 'Your assignment was added'
            rescue StandardError => e
              puts "FAILURE Creating Share Board: #{e.inspect}"
              flash[:error] = 'Could not add assignment.'
            ensure
              routing.redirect @share_board_route
            end
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

          share_board_data = Form::NewShareBoard.new.call(routing.params)
          if share_board_data.failure?
            flash[:error] = Form.message_values(share_board_data)
            routing.halt
          end
          CreateNewShareBoard.new(App.config).call(
            current_account: @current_account,
            share_board_data: share_board_data.to_h
          )

          flash[:notice] = 'Create a new ShareSoard'
        rescue StandardError => e
          puts "FAILURE Creating share board: #{e.inspect}"
          flash[:error] = 'Could not create share board'
        ensure
          routing.redirect @share_boards_route
        end
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
