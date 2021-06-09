# frozen_string_literal: true

require_relative 'form_base'

module CheckHigh
  module Form
    class NewAssignmentDetail < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/new_assignment_detail.yml')

      params do
        required(:assignment_name).filled(max_size?: 256, format?: FILENAME_REGEX)
        required(:assignment_name_valid?).filled
        required(:content).filled(:string)
      end
    end
  end
end