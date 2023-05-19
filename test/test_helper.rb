ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require_relative "helpers/mock_helpers"
require "rails/test_help"


class ActiveSupport::TestCase
  include MockHelpers
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

  def delete_test_data(dir)
    Dir.foreach(dir) do |file_name|
      next if ['.', '..'].include?(file_name) # Skip current directory and parent directory entries
      file_path = File.join(dir, file_name)
      File.delete(file_path) if File.file?(file_path)
    end
  end
end
