# frozen_string_literal: true

require 'pdfkit'

module CheckHigh
  # convert html file to pdf inline codes
  class ConvertPDF
    def initialize(content)
      @content = content
    end

    def convert
      kit = PDFKit.new(@content, page_size: 'Letter')
      kit.to_pdf
    end
  end
end
