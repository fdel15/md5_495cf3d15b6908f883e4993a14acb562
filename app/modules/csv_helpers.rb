# frozen_string_literal: true

##
# A wrapper around csv standard library to create consistency with interacting with
# CSV files
##
require "csv"

module CsvHelpers
  class NonIterableDataError < StandardError
    def message
      "Data must be iterable (array or object that responds to 'each')."
    end
  end

  def write_to_csv(data:, file_path:, headers: [], &block)
    raise NonIterableDataError unless data.respond_to?(:each)

    CSV.open(file_path, 'wb') do |csv|
      csv << headers unless headers.empty?

      data.each do |row|
        row = yield(row) if block_given? # allow data to be formatted by block
        csv << row
      end
    end
  end
end