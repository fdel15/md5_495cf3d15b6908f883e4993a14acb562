# frozen_string_literal: true

require "test_helper"

require_relative "../../helpers/open_ai_helpers"

class TestAnswerQuery < ActiveSupport::TestCase
  include Cosine

  def setup
    generate_stubbed_data
    @answer_query = OpenAi::AnswerQuery.new(
      query: Faker::Lorem.sentence,
      data_file: stubbed_data_file,
      embedder: stubbed_embedder
    )
  end

  def teardown
    delete_test_data(test_data_directory)
  end

  def test_fetch_answer_class_method
    chatbot = OpenAi::Chat.new

    expected = Faker::Lorem.sentence

    mock_method(
      object: chatbot,
      method: :create,
      mocked_result: expected
    )

    answer = OpenAi::AnswerQuery.fetch_answer(
      query: Faker::Lorem.sentence,
      data_file: stubbed_data_file,
      embedder: stubbed_embedder,
      chatbot: chatbot
    )

    assert_equal(answer, expected, "Should return message from chatbot")
  end

  def test_fetch_answer
    expected = Faker::Lorem.sentence

    mock_method(
      object: @answer_query.chatbot,
      method: :create,
      mocked_result: expected
    )

    answer = @answer_query.fetch_answer

    assert_equal(answer, expected, "Should return message from chatbot")
  end

  def test_prompt_content_truncated_to_stay_under_max_prompt_tokens
    mock_method(
      object: @answer_query,
      method: :max_tokens,
      mocked_result: 10
    )

    mock_method(
      object: @answer_query,
      method: :calculate_tokens,
      mocked_result: 5
    )

    sorted_array = @answer_query.sorted_similarity_array
    content_1, content_2, content_3 = sorted_array.map { |data| data.fetch('Content') }

    prompt_content = @answer_query.create_prompt_content
    expected = [content_1]

    assert_equal(prompt_content, expected)
  end

  def test_prompt_content_includes_all_content_if_under_max
    mock_method(
      object: @answer_query,
      method: :max_tokens,
      mocked_result: Float::INFINITY
    )

    sorted_array = @answer_query.sorted_similarity_array

    prompt_content = @answer_query.create_prompt_content
    expected = sorted_array.map { |data| data.fetch('Content') }

    assert_equal(prompt_content, expected)
  end

  def test_sorted_similar_array
    sorted_similarity_array = @answer_query.sorted_similarity_array
    sorted_similarities = sorted_similarity_array.map { |data| data.fetch('Similarity') }

    expected_embedding_order = [
      similar_embedding, perpendicular_embedding, unsimilar_embedding
    ]

    expected = expected_embedding_order.map do |embedding| 
      cosine_similarity(stubbed_query_embedding, embedding)
    end

    assert_equal(sorted_similarities, expected)
  end

  ##
  # Test Helpers
  ##

  def stubbed_embedder
    embedder = OpenAi::Embeddings.new
    mock_method(
      object: embedder,
      method: :create,
      mocked_result: stubbed_query_embedding
    )
    embedder
  end

  def stubbed_data_file
    "#{test_data_directory}/answer_query_data_file.csv"
  end

  def test_data_directory
    "#{Rails.root}/test/lib/open_ai/test_data"
  end

  def generate_stubbed_data
    headers = "Page #,Content,Embedding\n"
    embeddings = [similar_embedding, unsimilar_embedding, perpendicular_embedding].shuffle

    File.open(stubbed_data_file, 'w+') do |f|
      f.write headers

      embeddings.map.with_index do |embedding, page_num|
        content = Faker::Lorem.word
        f.write "#{page_num + 1},#{content},\"#{embedding}\"\n"
      end
    end
  end

  # values for query stub are chosen to make it simple to create similar,
  # unsimilar, and perpendicular embedding stubs
  def stubbed_query_embedding
    [1, -1, 1, -1, 1]
  end

  def similar_embedding
    stubbed_query_embedding
  end

  def unsimilar_embedding
    stubbed_query_embedding.map { |v| v * -1 }
  end

  # perpendicular vectors have a dot product of 0
  def perpendicular_embedding
    [1, 1, 1, 1, 0]
  end
end

