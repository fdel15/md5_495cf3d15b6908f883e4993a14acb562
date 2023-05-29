# frozen_string_literal: true

require "test_helper"

class TestCsvHelpers < ActiveSupport::TestCase
  include CsvHelpers
  def setup
    @output_directory = "#{Rails.root}/test/lib/test_data"
    @sample_csv = "#{Rails.root}/test/fixtures/files/sample.csv"
  end

  def teardown
    delete_test_data(@output_directory)
  end

  def test_write_to_csv_with_invalid_data
    data = rand(1..1000)
    file_path = generate_random_file_path

    assert_raises(NonIterableDataError) do
      write_to_csv(data: data, file_path: file_path)
    end
  end

  def test_write_to_csv_with_headers
    data_size = rand(1..10)
    headers = generate_random_data(data_size)
    data = Array.new(rand(1..10)) { generate_random_data(data_size) }
    file_path = generate_random_file_path

    write_to_csv(
      data: data,
      file_path: file_path,
      headers: headers
    )

    assert(File.exist?(file_path), "File should be generated")

    assert_equal(get_first_line(file_path), headers)

    file_data_without_headers = CSV.readlines(file_path)[1..-1]

    assert_equal(file_data_without_headers, data, "File should include data")
  end

  def test_write_to_csv_without_headers
    data_size = rand(1..10)
    data = Array.new(rand(1..10)) { generate_random_data(data_size) }
    file_path = generate_random_file_path

    write_to_csv(
      data: data,
      file_path: file_path
    )

    assert(File.exist?(file_path), "File should be generated")

    assert_equal(CSV.readlines(file_path), data)
  end

  def test_write_to_csv_with_block
    data_size = rand(1..10)
    data = Array.new(rand(1..10)) { generate_random_data(data_size) }
    file_path = generate_random_file_path

    lambda = ->(arr) { arr.map(&:upcase) }

    write_to_csv(
      data: data,
      file_path: file_path,
      &lambda
    )

    assert(File.exist?(file_path), "File should be generated")

    expected_data = data.map { |row| lambda.call(row) }
    assert_equal(expected_data, CSV.readlines(file_path))
  end

  def test_transform_csv_to_array
    array = transform_csv_to_array(@sample_csv)

    assert array.is_a?(Array)

    headers = get_first_line(@sample_csv)

    assert_not_equal(array.first, headers)

    first_line = CSV.read(@sample_csv, headers: true).first

    assert_equal(first_line, array.first)
  end

  def test_transform_csv_to_array_with_block
    random_data = Faker::Lorem.word

    arr = transform_csv_to_array(@sample_csv) { |row| row['Random'] = random_data; row }

    assert_equal(random_data, arr.first.fetch('Random'))
  end

  ##
  # Test Helper Methods
  ##
  def generate_random_file_path
    file_name = "file_#{rand(10_000_000)}.csv"
    "#{@output_directory}/#{file_name}"
  end

  def generate_random_data(size)
    Array.new(size) { Faker::Lorem.word }
  end

  def get_first_line(file)
    CSV.readlines(file).first
  end
end