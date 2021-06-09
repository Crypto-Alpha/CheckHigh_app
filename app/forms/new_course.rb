# frozen_string_literal: true

require_relative 'form_base'

module CheckHigh
  module Form
    class NewCourse < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/new_course.yml')

      params do
        required(:course_name).filled
        required(:links).filled(format?: URI::DEFAULT_PARSER.make_regexp)
      end
    end
  end
end