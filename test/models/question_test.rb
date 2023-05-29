# frozen_string_literal: true

require "test_helper"

class TestQuestion < Minitest::Test
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
end