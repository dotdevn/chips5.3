require "application_system_test_case"

class MoviesTest < ApplicationSystemTestCase
  setup do
    @movie = movies(:one)
  end

  test "visiting the index" do
    visit movies_url
    assert_selector "h1", text: "Movies"
  end

  test "should create movie" do
    visit movies_url
    click_on "New movie"

    fill_in "Description", with: @movie.description
    fill_in "Rating", with: @movie.rating
    fill_in "Release date", with: @movie.release_date
    fill_in "Title", with: @movie.title
    click_on "Create Movie"

    assert_text "Movie was successfully created"
    click_on "Back to movies"
  end

  test "should update Movie" do
    visit movie_url(@movie)
    click_on "Edit this movie", match: :first

    fill_in "Description", with: @movie.description
    fill_in "Rating", with: @movie.rating
    fill_in "Release date", with: @movie.release_date
    fill_in "Title", with: @movie.title
    click_on "Update Movie"

    assert_text "Movie was successfully updated"
    click_on "Back to movies"
  end

  test "should destroy Movie" do
    visit movie_url(@movie)
    click_on "Destroy this movie", match: :first

    assert_text "Movie was successfully destroyed"
  end

  test "filter and sort preferences survive navigation and can reset to all" do
    visit movies_url
    Movie.all_ratings.each { |rating| uncheck "ratings_#{rating}" unless rating == "G" }
    select "Release Date", from: "sort_by"
    click_on "Refresh"

    assert_selector "#movies tbody tr", count: 2
    assert_selector "#movies tbody tr:first-child td:first-child", text: "2001: A Space Odyssey"
    click_on "More about Aladdin"
    click_on "Back to movies"
    assert_checked_field "ratings_G"
    assert_unchecked_field "ratings_R"
    assert_selector "select#sort_by option:checked", text: "Release Date"
    assert_selector "#movies tbody tr", count: 2

    uncheck "ratings_G"
    click_on "Refresh"
    assert_selector "#movies tbody tr", count: Movie.count
    Movie.all_ratings.each { |rating| assert_checked_field "ratings_#{rating}" }
  end

  test "header links ignore checkbox changes that have not been submitted" do
    visit movies_url
    Movie.all_ratings.each { |rating| uncheck "ratings_#{rating}" unless rating == "G" }
    click_on "Refresh"
    check "ratings_R"
    click_on "Release Date", exact: true
    assert_selector "#movies tbody tr", count: 2
    assert_checked_field "ratings_G"
    assert_unchecked_field "ratings_R"
  end
end
