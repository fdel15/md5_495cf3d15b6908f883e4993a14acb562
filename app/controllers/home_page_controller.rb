class HomePageController < ApplicationController
  def index
    @data_file = embeddings_file_path
    @faqs = Question.faqs
  end

  private

  def embeddings_file_path
    ENV["EMBEDDINGS_FILE_PATH"] || "#{Rails.root}/embeddings/embeddings.csv"
  end
end
