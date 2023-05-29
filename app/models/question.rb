class Question < ApplicationRecord

  def self.find_by_query(query)
    query_md5_hash = query_md5_hash(query)
    find_by(:md5_hash, query_md5_hash)
  end

  def self.query_md5_hash(query)
    query = query.dup

    query.downcase!

    # remove all whitespace
    query.gsub!(' ', '')

    # remove all punctuation marks
    query.gsub!(/\p{P}/, '')

    Digest::MD5.hexdigest(query)
  end
end
