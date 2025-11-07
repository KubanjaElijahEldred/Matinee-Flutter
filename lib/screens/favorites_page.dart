import 'package:flutter/material.dart';
import 'package:movies/constants/api_constants.dart';
import 'package:movies/modal_class/movie.dart';
import 'package:movies/modal_class/genres.dart';
import 'package:movies/screens/movie_detail.dart';

class FavoritesPage extends StatefulWidget {
  final List<Genres> genres;
  
  FavoritesPage({required this.genres});
  
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  // In a real app, this would come from local storage or a database
  List<Movie> favoriteMovies = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Favorites',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Your favorite movies and shows',
            style: TextStyle(color: Colors.white60, fontSize: 16),
          ),
          SizedBox(height: 40),
          Expanded(
            child: favoriteMovies.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border, size: 80, color: Colors.white30),
                        SizedBox(height: 20),
                        Text(
                          'No favorites yet',
                          style: TextStyle(color: Colors.white60, fontSize: 18),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Start adding movies to your favorites!',
                          style: TextStyle(color: Colors.white38, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      childAspectRatio: 0.6,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: favoriteMovies.length,
                    itemBuilder: (context, index) {
                      final movie = favoriteMovies[index];
                      return _buildMovieCard(movie);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailPage(
              movie: movie,
              themeData: Theme.of(context),
              heroId: '${movie.id}fav',
              genres: widget.genres,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(TMDB_BASE_IMAGE_URL + 'w500/' + (movie.posterPath ?? '')),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            movie.title ?? '',
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
