class Movie < ApplicationRecord
  RATINGS = %w[G PG PG-13 R NC-17].freeze

  def self.all_ratings
    RATINGS
  end

  def self.with_ratings(ratings_list)
    return all if ratings_list.nil?

    where("UPPER(rating) IN (?)", ratings_list.map { |rating| rating.to_s.upcase })
  end
end
