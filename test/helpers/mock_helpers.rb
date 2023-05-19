# frozen_string_literal: true

module MockHelpers
  def mock_method(object:, method:, mocked_result:)
    object.define_singleton_method(method) do |*args|
      return mocked_result
    end
  end
end