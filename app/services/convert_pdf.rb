# frozen_string_literal: true

require 'pdfkit'

module CheckHigh
  # convert html file to pdf inline codes
  class ConvertPDF
    def initialize(assignment_detail)
      @assignment_detail = assignment_detail
    end

    def convert 
      content = @assignment_detail.content
      kit = PDFKit.new(content, page_size: 'Letter')
      kit.to_pdf
    end

    def self.get_file_name(assignment_detail)
      name = assignment_detail.assignment_name
      name.slice!('.html')
      "#{name}.pdf"
    end
  end
end
