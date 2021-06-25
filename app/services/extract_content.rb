# frozen_string_literal: true

require_relative 'convert_pdf'

module CheckHigh
  # extract assignment info from upload form file
  class ExtractContent
    def initialize(assignment_data)
      @type = assignment_data[:type]
      @assignment_name = assignment_data[:filename]
      @file_path = assignment_data[:tempfile]
    end

    def extract
      content = if @type == 'text/html'
                  ConvertPDF.new(@file_path.read).convert
                else
                  @file_path.read
                end
      {
        assignment_name: @assignment_name,
        content: content
      }
    end
  end
end
