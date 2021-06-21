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

        # POST /assignments/[assignment_id]/rename_assignment
        # form didn't enable put method
        routing.post('rename_assignment') do
          puts "ASSIGNMENT NEW NAME: #{routing.params}"
          redirect_route = routing.params['redirect_route']
          name_validation = Form::RenameRules.new.call(routing.params)
          if name_validation.failure?
            flash[:error] = Form.message_values(routing.params)
            routing.halt
          end

          new_name = { 'new_name' => routing.params['new_name'] }
          RenameAssignment.new(App.config).call(@current_account, assignment_id, new_name)

          flash[:notice] = "You've renamed an assignment"
        rescue StandardError => e
          puts "FAILURE Renaming Assignment: #{e.inspect}"
          flash[:error] = 'Could not rename a Assignment'
        ensure
          routing.redirect redirect_route
        end

        # POST /assignments/[assignment_id]/deletion
        # form didn't enable put method
        routing.post('deletion') do
          redirect_route = routing.params['redirect_route']
          RemoveAssignment.new(App.config).call(@current_account, assignment_id)

          flash[:notice] = "You've removed an assignment"
        rescue StandardError => e
          puts "FAILURE Removing a Lonely Assignment: #{e.inspect}"
          flash[:error] = 'Could not remove a Lonely Assignment'
        ensure
          routing.redirect redirect_route
        end

        # POST /assignments/[assignment_id]/move_assignment_to_course
        routing.post('move_assignment_to_course') do
          redirect_route = routing.params['redirect_route']
          course_id = routing.params['course_id']

          if course_id.include? '_r'
            course_id.sub!('_r', '')
            RemoveAssiFromCourse.new(App.config).call(@current_account, assignment_id, course_id)
            notice = 'Your assignment has removed from the course'
          else
            MoveAssiToCourse.new(App.config).call(@current_account, assignment_id, course_id)
            notice = 'You have moved you assignment to the course'
          end

          flash[:notice] = notice
        rescue StandardError => e
          puts "FAILURE Moving an assignment: #{e.inspect}"
          flash[:error] = 'Could not move an assignment'
        ensure
          routing.redirect redirect_route
        end

        # POST /assignments/[assignment_id]/move_assignment_to_share_board
        routing.post('move_assignment_to_share_board') do
          redirect_route = routing.params['redirect_route']
          share_board_id = routing.params['share_board_id']

          if share_board_id.include? '_r'
            share_board_id.sub!('_r', '')
            RemoveAssiFromShareBoard.new(App.config).call(@current_account, assignment_id, share_board_id)
            notice = 'Your assignment has removed from the share board'
          else
            CreateNewAssignment.new(App.config).add_exist_assi_to_shareboard(
              current_account: @current_account,
              share_board_id: share_board_id,
              assignment_id: assignment_id
            )
            notice = 'Your assignment was added'
          end

          flash[:notice] = notice
        rescue StandardError => e
          puts "FAILURE Creating Assignment: #{e.inspect}"
          flash[:error] = 'Could not add assignment. You might have already added this assignment before.'
        ensure
          routing.redirect redirect_route
        end

        # GET /assignments/[assignment_id]/export
        routing.get('export') do
          assignment = GetAssignmentDetail.new(App.config).call(@current_account, assignment_id)
          assignment_detail = AssignmentDetail.new(assignment)
          # export to pdf
          export_service = ExportPDF.new(assignment_detail)
          file = export_service.export

          response['Content-Type'] = 'application/pdf'
          response['Content-Disposition'] = 'attachment'
          response.write(file)
        rescue StandardError => e
          puts "FAILURE Exporting pdf file: #{e.inspect}"
          flash[:error] = 'Could not export your assignment.'
        end

        routing.is do 
          # GET /assignments/[assignment_id]
          routing.get do
            assignment = GetAssignmentDetail.new(App.config).call(@current_account, assignment_id)
            assignment_detail = AssignmentDetail.new(assignment)

            courses_list = GetAllCourses.new(App.config).call(@current_account)
            share_board_list = GetAllShareBoards.new(App.config).call(@current_account)
            courses = Courses.new(courses_list)
            share_boards = ShareBoards.new(share_board_list)

            in_srb = assignment_detail.share_boards.map(&:id)

            # export to pdf
            pdf_file_name = ExportPDF.get_file_name(assignment_detail) 

            view :assignment, locals: {
              current_user: @current_account,
              assignment: assignment_detail,
              all_courses: courses,
              all_share_boards: share_boards,
              in_srb: in_srb,
              pdf_file_name: pdf_file_name
            }
          rescue StandardError => e
            puts "#{e.inspect}\n#{e.backtrace}"
            flash[:error] = 'Assignment not found'
            routing.redirect @home_route
          end
        end
      end

      # POST /assignments
      routing.post do
        routing.redirect '/auth/login' unless @current_account.logged_in?
        puts "ASSIGNMENT: #{routing.params}"
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
