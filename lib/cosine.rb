# frozen_string_literal: true

module Cosine
  ##
  # cosine_similarity(A, B) = dot_product(A, B) / (||A|| * ||B||)
  #
  # dot_product = sum of the product of corresponding elements in the vector
  #  e.g v1 = [1, 2, 3], v2 = [4, 5, 6], dp = (1 * 4) + (2 * 5) + (3 * 6)
  #
  # ||A|| and ||B|| are the magnitudes (or lengths) of vectors A and B, respectively.
  # magnitude of a vector is calculated as the square root of the sum of the squares of its elements
  #  e.g ||v1|| = Math.sqrt((1 * 1) + (2 * 2) + (3 * 3))
  ##
  def cosine_similarity(vector_a, vector_b)
    validate_inputs_are_arrays(vector_a, vector_b)
    validate_inputs_are_same_size(vector_a, vector_b)
 
    dot_product = 0
    vector_a.zip(vector_b).each do |v1i, v2i|
      dot_product += v1i * v2i
    end

    square_sum_a = vector_a.map { |n| n ** 2 }.reduce(:+)
    square_sum_b = vector_b.map { |n| n ** 2 }.reduce(:+)

    magnitude_a = Math.sqrt(square_sum_a)
    magnitude_b = Math.sqrt(square_sum_b)

    dot_product / (magnitude_a * magnitude_b)
  end

  def validate_inputs_are_arrays(a, b)
    unless a.is_a?(Array) && b.is_a?(Array)
      raise CosineError.new("Both input vectors need to be arrays")
    end
  end

  def validate_inputs_are_same_size(a, b)
    raise CosineError.new("Vectors need to be the same size") if a.size != b.size  
  end

  class CosineError < StandardError; end
end