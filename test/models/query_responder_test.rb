# frozen_string_literal: true

require "test_helper"

class TestQueryResponder < ActiveSupport::TestCase
  def setup
  end

  def test_fetch_answer_when_question_exists
    
  end

  def test_fetch_answer_for_new_question
    responder = 'open_ai'
    chatbot = OpenAi::Chat.new
    expected = Faker::Lorem.sentence

    mock_method(
      object: chatbot,
      method: :create,
      mocked_result: expected
    )

    answer = QueryResponder.fetch_answer(
      query: Faker::Lorem.sentence,
      data_file: Faker::Lorem.word,
      responder: responder,
      chatbot: chatbot,
      generate_prompt: false
    )

    assert_equal(answer, expected, "Should return message from chatbot")
  end
end