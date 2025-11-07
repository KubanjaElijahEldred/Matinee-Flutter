const String TMDB_API_KEY = "21c391eeb52e20048513ce13e564118d";
const String TMDB_API_BASE_URL = "https://api.themoviedb.org/3";

class Endpoints {
  static String discoverMoviesUrl(int page) {
    return '$TMDB_API_BASE_URL/discover/movie?api_key=$TMDB_API_KEY'
        '&language=en-US&sort_by=popularity.desc'
        '&include_adult=false&include_video=false&page=$page';
  }

  static String nowPlayingMoviesUrl(int page) {
    return '$TMDB_API_BASE_URL/movie/now_playing?api_key=$TMDB_API_KEY'
        '&include_adult=false&page=$page';
  }

  static String getCreditsUrl(int id) {
    return '$TMDB_API_BASE_URL/movie/$id/credits?api_key=$TMDB_API_KEY';
  }

  static String topRatedUrl(int page) {
    return '$TMDB_API_BASE_URL/movie/top_rated?api_key=$TMDB_API_KEY'
        '&include_adult=false&page=$page';
  }

  static String popularMoviesUrl(int page) {
    return '$TMDB_API_BASE_URL/movie/popular?api_key=$TMDB_API_KEY'
        '&include_adult=false&page=$page';
  }

  static String upcomingMoviesUrl(int page) {
    return '$TMDB_API_BASE_URL/movie/upcoming?api_key=$TMDB_API_KEY'
        '&include_adult=false&page=$page';
  }

  static String movieDetailsUrl(int movieId) {
    return '$TMDB_API_BASE_URL/movie/$movieId?api_key=$TMDB_API_KEY&append_to_response=credits,images';
  }

  static String genresUrl() {
    return '$TMDB_API_BASE_URL/genre/movie/list?api_key=$TMDB_API_KEY&language=en-US';
  }

  static String getMoviesForGenre(int genreId, int page) {
    return '$TMDB_API_BASE_URL/discover/movie?api_key=$TMDB_API_KEY'
        '&language=en-US'
        '&sort_by=popularity.desc'
        '&include_adult=false'
        '&include_video=false'
        '&page=$page'
        '&with_genres=$genreId';
  }

  static String movieReviewsUrl(int movieId, int page) {
    return '$TMDB_API_BASE_URL/movie/$movieId/reviews?api_key=$TMDB_API_KEY'
        '&language=en-US&page=$page';
  }

  static String movieSearchUrl(String query) {
    return "$TMDB_API_BASE_URL/search/movie?query=$query&api_key=$TMDB_API_KEY";
  }

  static String personSearchUrl(String query) {
    return "$TMDB_API_BASE_URL/search/person?query=$query&api_key=$TMDB_API_KEY";
  }

  static String getPerson(int personId) {
    return "$TMDB_API_BASE_URL/person/$personId?api_key=$TMDB_API_KEY&append_to_response=movie_credits";
  }

  static String getMovieVideos(int movieId) {
    return "$TMDB_API_BASE_URL/movie/$movieId/videos?api_key=$TMDB_API_KEY";
  }

  // TV Shows endpoints
  static String discoverTVUrl(int page) {
    return '$TMDB_API_BASE_URL/discover/tv?api_key=$TMDB_API_KEY'
        '&language=en-US&sort_by=popularity.desc'
        '&include_adult=false&page=$page';
  }

  static String topRatedTVUrl(int page) {
    return '$TMDB_API_BASE_URL/tv/top_rated?api_key=$TMDB_API_KEY'
        '&page=$page';
  }

  static String popularTVUrl(int page) {
    return '$TMDB_API_BASE_URL/tv/popular?api_key=$TMDB_API_KEY'
        '&page=$page';
  }

  static String airingTodayTVUrl(int page) {
    return '$TMDB_API_BASE_URL/tv/airing_today?api_key=$TMDB_API_KEY'
        '&page=$page';
  }

  static String tvSearchUrl(String query) {
    return "$TMDB_API_BASE_URL/search/tv?query=$query&api_key=$TMDB_API_KEY";
  }

  static String getTVDetailsUrl(int tvId) {
    return '$TMDB_API_BASE_URL/tv/$tvId?api_key=$TMDB_API_KEY&append_to_response=credits,images';
  }

  static String getTVVideos(int tvId) {
    return "$TMDB_API_BASE_URL/tv/$tvId/videos?api_key=$TMDB_API_KEY";
  }

  static String getTVGenres() {
    return '$TMDB_API_BASE_URL/genre/tv/list?api_key=$TMDB_API_KEY&language=en-US';
  }

  static String getTVForGenre(int genreId, int page) {
    return '$TMDB_API_BASE_URL/discover/tv?api_key=$TMDB_API_KEY'
        '&language=en-US'
        '&sort_by=popularity.desc'
        '&page=$page'
        '&with_genres=$genreId';
  }
}
