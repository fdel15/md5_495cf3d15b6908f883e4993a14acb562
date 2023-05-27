# frozen_string_literal: true

require "test_helper"

class TestCosine < ActiveSupport::TestCase
  include Cosine

  def setup
    @vector_a = generate_random_vector
    @vector_b = generate_random_vector
  end

  def teardown
  end

  def test_cosine_similarity_with_invalid_inputs
    @vector_b = @vector_b.to_s

    assert_raises(Cosine::CosineError, "Raises error if vectors are not arrays") do
      cosine_similarity(@vector_a, @vector_b)
    end

    @vector_a = generate_random_vector(5)
    @vector_b = generate_random_vector(4)

    assert_raises(Cosine::CosineError, "Raises error if vector lengths are not equal") do
      cosine_similarity(@vector_a, @vector_b)
    end
  end

  def test_cosine_similarity_with_valid_inputs
    @vector_b = @vector_a

    assert_in_delta(1, cosine_similarity(@vector_a, @vector_b), 0.0001, "Returns 1 when vectors are the same")

    @vector_b = @vector_a.map { |v| v * -1 }

    assert_in_delta(-1, cosine_similarity(@vector_a, @vector_b), 0.0001, "Returns -1 when vectors are opposite")

    # If two vectors are perpendicular, then their dot-product is equal to zero
    @vector_a = [1, 1, 1, 1, 1]
    @vector_b = [1, -1, 1, -1, 0]
    
    assert_equal(0, cosine_similarity(@vector_a, @vector_b), "Returns 0 when vectors are perpendicular")
  end

  ##
  # Test Helper Methods
  ##
  def generate_random_vector(vector_length = 5)
    vector_length.downto(1).map { |_| rand(-1.to_f..1.to_f) }
  end
end