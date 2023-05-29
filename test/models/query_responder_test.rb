# frozen_string_literal: true

require "test_helper"

class TestQueryResponder < ActiveSupport::TestCase
  def setup
  end

  def test_fetch_answer_when_question_exists
    question = questions(:first_question)
    query = question.query_text

    expected_answer = question.answer_text
    expected_number_of_times_asked = question.number_of_times_asked + 1
    expected_number_of_questions = Question.count

    answer = QueryResponder.fetch_answer(
      query: query,
      data_file: Faker::Lorem.word
    )

    assert_equal(expected_answer, answer, "Should return existing answer for question")
    assert_equal(expected_number_of_times_asked, question.reload.number_of_times_asked, "Should increment the number of times the question was asked")
    assert_equal(expected_number_of_questions, Question.count, "Should not create a new question")
  end

  def test_fetch_answer_for_new_question
    responder = 'open_ai'
    chatbot = OpenAi::Chat.new
   
    expected_question_count = Question.count + 1
    expected_answer = Faker::Lorem.sentence

    mock_method(
      object: chatbot,
      method: :create,
      mocked_result: expected_answer
    )

    answer = QueryResponder.fetch_answer(
      query: Faker::Lorem.sentence,
      data_file: Faker::Lorem.word,
      responder: responder,
      chatbot: chatbot,
      generate_prompt: false
    )

    assert_equal(expected_answer, answer, "Should return message from chatbot")
    assert_equal(expected_question_count, Question.count, "Should create a new Question")
  end
end