# frozen_string_literal: true

require_relative 'form_base'

module CheckHigh
  module Form
    class NewCourse < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/new_course.yml')

      params do
        required(:course_name).filled(max_size?: 256, format?: FILENAME_REGEX)
      end
    end
  end
end
