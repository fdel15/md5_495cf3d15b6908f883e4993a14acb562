# frozen_string_literal: true

require "test_helper"

class TestEmbeddingsGenerator < ActiveSupport::TestCase
  def setup
    @embeddings_generator = EmbeddingsGenerator.new
    @sample_pdf = "#{Rails.root}/test/fixtures/files/sample.pdf"
    @sample_csv = "#{Rails.root}/test/fixtures/files/sample.csv"
    @output_directory = "#{Rails.root}/test/models/test_data"
  end

  def teardown
    delete_test_data(@output_directory)
  end

  def test_create_pages_csv
    csv_file_name = 'sample.csv'
    @embeddings_generator.create_pages_csv(
      pdf_file_path: @sample_pdf,
      csv_file_name: csv_file_name,
      output_directory: @output_directory
    )

    output_file = "#{@output_directory}/#{csv_file_name}"

    assert File.exist?(output_file), "Should generate CSV output file"

    output_file_hash = Digest::SHA256.file(output_file).hexdigest

    # Expected file has been hand checked to ensure accuracy
    # This is brittle because if we change encoder or headers then this test
    # will fail
    # In that situation we should handcheck the output and store it as the new
    # sample.csv
    # This can probably be improved to be less brittle
    expected_file_hash = Digest::SHA256.file(@sample_csv).hexdigest

    assert_equal(output_file_hash, expected_file_hash)
  end
end

