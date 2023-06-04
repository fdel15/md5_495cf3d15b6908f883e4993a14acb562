class HomePageController < ApplicationController
  def index
    @data_file = embeddings_file_path
    @faqs = Question.faqs
    @book_image = book_image
  end

  private

  def embeddings_file_path
    ENV["EMBEDDINGS_FILE_PATH"] || "#{Rails.root}/embeddings/embeddings.csv"
  end

  def book_image
    ENV.fetch("BOOK_IMAGE") { 'book-covers.jpg' }
  end
end
