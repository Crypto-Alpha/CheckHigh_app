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
      if @type == 'text/html'
        origin_content = @file_path.read
        # convert to pdf 
        convert_service = ConvertPDF.new(origin_content)
        converted_content = convert_service.convert
        {
          assignment_name: @assignment_name,
          content: converted_content 
        }

      else 
        {
          assignment_name: @assignment_name,
          content: @file_path.read
        }
      end
    end
  end
end
