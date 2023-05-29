# frozen_string_literal: true

require_relative 'helpers'

module OpenAi
  class AnswerQuery
    include Cosine
    include CsvHelpers
    include OpenAiHelpers 

    SIMILARITY_KEY = 'Similarity'

    attr_reader :data_file, :chatbot, :embedder, :generate_prompt, :query

    def initialize(
      query:,
      data_file:,
      embedder: OpenAi::Embeddings.new,
      chatbot: OpenAi::Chat.new,
      generate_prompt: true
    )
      @query = query
      @data_file = data_file
      @embedder = embedder
      @chatbot = chatbot
      @generate_prompt = generate_prompt
    end

    def self.fetch_answer(**kwargs)
      obj = new(**kwargs)
      obj.fetch_answer
    end

    def fetch_answer
      content = create_prompt_content
      chatbot.create(query: query, content: content)
    end

    def create_prompt_content
      return [] unless generate_prompt

      token_count = calculate_tokens(query, tokenizer)
      prompt_content = []

      sorted_similarity_array.each do |data|
        content = data.fetch('Content')
        token_count += calculate_tokens(content, tokenizer)
        
        break if token_count > max_tokens

        prompt_content << content
      end

      prompt_content
    end

    def sorted_similarity_array
      @sorted_similarity_array ||= sort_similarity_array
    end

    private

    def query_embedding
      @query_embedding ||= embedder.create(query)
    end

    def similarity_array
      @similarity_array ||= generate_similarity_array
    end

    def sort_similarity_array
      similarity_array.sort_by { |data| data.fetch(SIMILARITY_KEY) }.reverse
    end

    def generate_similarity_array
      transform_csv_to_array(data_file) do |row|
        row_embedding = JSON.parse(row["Embedding"]) # JSON.parse transforms string to array
        similarity = cosine_similarity(query_embedding, row_embedding)
        row[SIMILARITY_KEY] = similarity
        row.to_h
      end
    end

    def tokenizer
      chatbot.tokenizer
    end

    def max_tokens
      chatbot.max_prompt_tokens
    end
  end
end
