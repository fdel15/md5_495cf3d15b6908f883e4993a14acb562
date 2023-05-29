class Question < ApplicationRecord

  before_create :set_uuid
  before_create :set_md5_hash

  def self.find_by_query(query)
    query_md5_hash = query_md5_hash(query)
    find_by(md5_hash: query_md5_hash)
  end

  ##
  # Try to remove as much information as possible without changing the query
  # before creating the md5_hash to increase the number of queries that should
  # have the same answer to also have the same md5 hash
  # e.g. What is the capital of Paris?
  #                                     ===> same MD5 hash
  #      What is the capital   of Paris
  ##
  def self.query_md5_hash(query)
    query = query.dup

    query.downcase!

    # remove all whitespace
    query.gsub!(' ', '')

    # remove all punctuation marks
    # . , ! ? ' " : ; ( ) [ ] { } - _ / \ | & * + = < > ^ $ % @ ~ # ` and others
    # https://ruby-doc.org/core-2.7.1/Regexp.html#class-Regexp-label-Character+Properties
    query.gsub!(/\p{P}/, '')

    Digest::MD5.hexdigest(query)
  end

  def increment_number_of_times_asked
    self.increment!(:number_of_times_asked)
  end

  private

  def set_md5_hash
    self.md5_hash = self.class.query_md5_hash(query_text)
  end
end
