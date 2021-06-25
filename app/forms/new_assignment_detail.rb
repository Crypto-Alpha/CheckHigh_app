# frozen_string_literal: true

require_relative 'form_base'

module CheckHigh
  module Form
    # create assignment detail form
    class NewAssignmentDetail < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/new_assignment_detail.yml')

      params do
        required(:filename).filled(max_size?: 256, format?: FILENAME_REGEX)
        required(:tempfile).filled
        required(:type).filled(format?: FILETYPE_REGEX)
        # not knowing what to test
      end
    end
  end
end
