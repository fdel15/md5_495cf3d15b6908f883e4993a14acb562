class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  ##
  # Not needed if we use postgresDB
  # SQLite DB does not have uuid type
  ##
  def set_uuid
    self.id = SecureRandom.uuid
  end
end
