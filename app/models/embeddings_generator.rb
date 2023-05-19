# frozen_string_literal: true

class EmbeddingsGenerator
  include CsvHelpers
  EMBEDDINGS_DIRECTORY = "#{Rails.root}/embeddings"
  DEFAULT_EMBEDDER = OpenAi::Embeddings.new

  attr_reader :embedder
  def initialize(embedder: DEFAULT_EMBEDDER)
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
    pages_csv_file_path:,
    output_file_name:,
    output_directory: EMBEDDINGS_DIRECTORY
  )
    data = get_embeddings_from_pages(pages_csv_file_path)
    file_path = "#{output_directory}/#{output_file_name}"

    write_to_csv(
      data: data,
      file_path: file_path,
      headers: embeddings_csv_headers
    )
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

  def calculate_tokens(text)
    embedder.calculate_tokens(text)
  end

  def embeddings_csv_headers
    num_of_vectors = embedder.output_dimensions
    vector_columns = (0..num_of_vectors - 1).to_a
    ["Page #"] + vector_columns
  end

  # Assumes pages to have the following headers:
  # ["Page #", "Content", "# of Tokens"]
  def get_embeddings_from_pages(file_path)
    embeddings = []
    CSV.foreach(file_path, headers: true) do |row|
      page_number = row["Page #"]
      content = row["Content"]

      embedding = get_embedding(content)
      embeddings << [page_number] + embedding

    rescue OpenAi::MaxTokenError
      # TODO: It would be better to do more than rescue this error by logging
      puts "Skipping #{page_number} because its token count is greater than the max token count"
    end

    embeddings
  end

  def get_embedding(text)
    embedder.create(text)
  end
end