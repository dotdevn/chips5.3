require "test_helper"

class MovieTest < ActiveSupport::TestCase
  test "all ratings are available even when no movie has that rating" do
    Movie.delete_all
    assert_equal %w[G PG PG-13 R NC-17], Movie.all_ratings
  end

  test "ratings filter accepts mixed case and stays chainable" do
    movies(:raiders).update!(rating: "pg")
    scope = Movie.with_ratings(%w[g pG])
    assert_kind_of ActiveRecord::Relation, scope
    assert_equal [movies(:one), movies(:space_odyssey), movies(:raiders)].map(&:id).sort, scope.pluck(:id).sort
  end

  test "nil ratings include every movie and an empty array matches none" do
    assert_equal Movie.count, Movie.with_ratings(nil).count
    assert_empty Movie.with_ratings([])
  end

  test "rating input is quoted rather than treated as SQL" do
    assert_empty Movie.with_ratings(["G') OR 1=1 --"])
  end

  test "titles sort in Ruby string order including punctuation and case" do
    Movie.create!(title: "a lowercase title", rating: "G")
    Movie.create!(title: "!First", rating: "G")
    assert_equal Movie.pluck(:title).sort, Movie.sorted_by("title").pluck(:title)
  end

  test "release dates sort earliest first" do
    assert_equal Movie.pluck(:release_date).sort, Movie.sorted_by("release_date").pluck(:release_date)
  end

  test "sort column is allowlisted" do
    assert_equal Movie.sorted_by("title").pluck(:id), Movie.sorted_by("title; DROP TABLE movies").pluck(:id)
  end
end
