# frozen_string_literal: true

require "test_helper"
require_relative "../helpers/open_ai_helpers"

class TestEmbeddingsGenerator < ActiveSupport::TestCase
  def setup
    @embeddings_generator = EmbeddingsGenerator.new
    @sample_pdf = "#{Rails.root}/test/fixtures/files/sample.pdf"
    @sample_pages_csv = "#{Rails.root}/test/fixtures/files/sample.csv"
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
    expected_file_hash = Digest::SHA256.file(@sample_pages_csv).hexdigest

    assert_equal(output_file_hash, expected_file_hash)
  end

  def test_create_embeddings_csv
    pages_csv_file_path = @sample_pages_csv
    output_file_name = "#{Faker::Lorem.word}.csv"
    output_directory = @output_directory
    embedder = @embeddings_generator.embedder

    OpenAiHelpers::Embeddings.mock_embeddings_request(embedder.client)

    @embeddings_generator.create_embeddings_csv(
      pages_csv_file_path: pages_csv_file_path,
      output_file_name: output_file_name,
      output_directory: output_directory
    )

    output_file = "#{@output_directory}/#{output_file_name}"

    assert File.exist?(output_file), "Should generate CSV output file"

    lines = CSV.readlines(output_file)
    output_dimensions = embedder.output_dimensions

    assert_equal(
      lines.first.length, output_dimensions + 1, 
      "Output file should contain column for each output dimension plus a title column"
    )
  end
end

