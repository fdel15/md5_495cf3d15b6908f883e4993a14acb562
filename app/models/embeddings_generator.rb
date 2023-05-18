# frozen_string_literal: true

class EmbeddingsGenerator
  include CsvHelpers
  EMBEDDINGS_DIRECTORY = "#{Rails.root}/embeddings"

  attr_reader :embedder
  def initialize(embedder: OpenAI::Embedder.new)
    @embedder = embedder
  end

  def create_pages_csv(
    pdf_file_path:,
    csv_file_name:,
    output_directory: EMBEDDINGS_DIRECTORY
  )
    headers = ["Page #", "Content", "# of Tokens"]
    content = extract_pdf_text(pdf_file_path)
    data = create_pages_csv_data(content)
    file_path = "#{output_directory}/#{csv_file_name}"
    write_to_csv(data: data, file_path: file_path, headers: headers)
  end

  def create_embeddings_csv(
    data_csv_file_path:,
    output_file_name:,
    output_directory: EMBEDDINGS_DIRECTORY
  )
    # headers = title + 0 --> max vector columns
    # data = get embedding
    # file_path = "#{output_directory}/#{title}.csv"
  end

  private

  # pdf-reader gem
  def pdf_reader
    PDF::Reader
  end

  def extract_pdf_text(pdf_file_name)
    pdf = pdf_reader.new(pdf_file_name)
    pdf.pages.map { |page| format_extracted_text(page.text) }
  end

  # Removes white space and formats
  def format_extracted_text(string)
    string.split.join(' ')
  end

  def create_pages_csv_data(content)
    content.map.with_index { |text, index| create_page_csv_data(text, index + 1) }
  end

  # Assumes csv headers will be
  # ["Page #", "Content", "# of Tokens"] 
  def create_page_csv_data(text, page_number)
    [page_number, text, calculate_tokens(text)]
  end

  # We should make the encoding an ENV to easily switch
  def calculate_tokens(text)
    encoder = Tiktoken.get_encoding("cl100k_base")
    encoder.encode(text).length
  end
end