require "test_helper"
require "uri"

class MoviePreferencesTest < ActionDispatch::IntegrationTest
  test "first visit shows every movie and checks every rating" do
    get movies_path
    assert_response :success
    assert_equal Movie.count, movie_rows.length
    assert_checked_ratings Movie.all_ratings
    assert_select "form#ratings_form[method=get]" do
      assert_select "input#ratings_submit[type=submit][value=Refresh]"
      assert_select "select#sort_by option[selected][value=title]"
    end
  end

  test "refresh filters to selected ratings and keeps their checkboxes checked" do
    get movies_path, params: { ratings: { "G" => "1", "R" => "1" }, filter_submitted: "1" }
    assert_response :success
    assert_equal Movie.with_ratings(%w[G R]).sorted_by("title").pluck(:title), movie_titles
    assert_checked_ratings %w[G R]
  end

  test "refresh with no checked ratings resets a previous filter to all" do
    get movies_path, params: { ratings: { "G" => "1" }, sort_by: "release_date" }
    get movies_path, params: { filter_submitted: "1", sort_by: "release_date" }
    assert_equal Movie.count, movie_rows.length
    assert_checked_ratings Movie.all_ratings
    assert_select "#sort_by option[selected][value=release_date]"
  end

  test "an empty ratings hash or the standard refresh submit also resets to all" do
    get movies_path, params: { ratings: { "G" => "1" } }
    get movies_path, params: { ratings: {}, commit: "Refresh" }
    assert_checked_ratings Movie.all_ratings
    assert_equal Movie.count, movie_rows.length
  end

  test "sort and filter work together in either order" do
    get movies_path, params: { ratings: { "PG" => "1", "G" => "1" }, sort_by: "release_date" }
    assert_equal Movie.with_ratings(%w[PG G]).sorted_by("release_date").pluck(:title), movie_titles
    assert_checked_ratings %w[G PG]
    assert_select "#sort_by option[selected][value=release_date]"

    get movies_path, params: { ratings: { "R" => "1" }, filter_submitted: "1" }
    assert_equal [movies(:two).title], movie_titles
    assert_select "#sort_by option[selected][value=release_date]"
  end

  test "column links preserve only the last submitted ratings" do
    get movies_path, params: { ratings: { "G" => "1", "PG" => "1" }, sort_by: "title" }
    link = css_select("a#release_date_header").first["href"]
    query = Rack::Utils.parse_nested_query(URI.parse(link).query)
    assert_equal({ "G" => "1", "PG" => "1" }, query["ratings"])
    assert_equal "release_date", query["sort_by"]
    get link
    assert_checked_ratings %w[G PG]
    assert_equal Movie.with_ratings(%w[G PG]).sorted_by("release_date").pluck(:title), movie_titles
  end

  test "settings survive movie details and a plain back to movies link" do
    get movies_path, params: { ratings: { "G" => "1" }, sort_by: "release_date" }
    get movie_path(movies(:one))
    assert_response :success
    get movies_path
    assert_checked_ratings %w[G]
    assert_select "#sort_by option[selected][value=release_date]"
    assert_equal Movie.with_ratings(["G"]).sorted_by("release_date").pluck(:title), movie_titles
  end

  test "explicit parameters override saved preferences" do
    get movies_path, params: { ratings: { "R" => "1" }, sort_by: "release_date" }
    get movies_path, params: { ratings: { "PG" => "1" }, sort_by: "title" }
    get movies_path
    assert_checked_ratings %w[PG]
    assert_equal [movies(:raiders).title], movie_titles
    assert_select "#sort_by option[selected][value=title]"
  end

  test "preferences are private to each browser session" do
    get movies_path, params: { ratings: { "R" => "1" }, sort_by: "release_date" }
    other_browser = open_session
    other_browser.get movies_path
    other_browser.assert_select "#movies tbody tr", count: Movie.count
    other_browser.assert_select "#ratings_form input[type=checkbox][checked]", count: Movie.all_ratings.length
  end

  test "invalid query parameters cannot become SQL or raise an exception" do
    get movies_path, params: { ratings: "not-a-hash", sort_by: "title; DROP TABLE movies" }
    assert_response :success
    assert_checked_ratings Movie.all_ratings
    assert_equal Movie.sorted_by("title").pluck(:title), movie_titles
  end

  private

  def movie_rows
    css_select("#movies tbody tr")
  end

  def movie_titles
    movie_rows.map { |row| row.at_css("td").text }
  end

  def assert_checked_ratings(expected)
    checked = css_select("#ratings_form input[type=checkbox][checked]").map { |input| input["id"].delete_prefix("ratings_") }
    assert_equal expected.sort, checked.sort
  end
end
