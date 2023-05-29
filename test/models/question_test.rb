# frozen_string_literal: true

require "test_helper"

class TestQuestion < ActiveSupport::TestCase
  def test_query_md5_hash
    expected = Digest::MD5.hexdigest('helloworld')

    assert_equal(expected, Question.query_md5_hash("Hello, world!"))
    assert_equal(expected, Question.query_md5_hash("Hello world!!"))
    assert_equal(expected, Question.query_md5_hash("Hello... world???"))
    assert_equal(expected, Question.query_md5_hash("HELLO WORLD"))
    assert_equal(expected, Question.query_md5_hash("h e l l o w o r l d"))
    assert_equal(expected, Question.query_md5_hash("      hello World"))
    assert_equal(expected, Question.query_md5_hash("hello world       "))
    assert_equal(expected, Question.query_md5_hash(", hello world"))
    assert_equal(expected, Question.query_md5_hash("hellO world;"))
    assert_equal(expected, Question.query_md5_hash("hello worl'd"))
  end

  def test_uuid_is_set_on_create
    query = Faker::Lorem.sentence
    answer = Faker::Lorem.sentence
    question = Question.create(query_text: query, answer_text: answer)

    assert(question.reload.id)
  end

  def test_md5_hash_is_set_on_create
    query = Faker::Lorem.sentence
    answer = Faker::Lorem.sentence
    expected_md5_hash = Question.query_md5_hash(query)
    question = Question.create(query_text: query, answer_text: answer)

    assert_equal(expected_md5_hash, question.reload.md5_hash)
  end

  def test_increment_number_of_times_asked
    question = questions(:first_question)
    expected = question.number_of_times_asked + 1
    question.increment_number_of_times_asked
    assert_equal(expected, question.reload.number_of_times_asked)
  end
end