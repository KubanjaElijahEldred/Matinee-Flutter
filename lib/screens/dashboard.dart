import 'package:flutter/material.dart';
import 'package:movies/api/endpoints.dart';
import 'package:movies/constants/api_constants.dart';
import 'package:movies/modal_class/function.dart';
import 'package:movies/modal_class/genres.dart';
import 'package:movies/modal_class/movie.dart';
import 'package:movies/modal_class/video.dart';
import 'package:movies/screens/movie_detail.dart';
import 'package:movies/screens/trailer_player.dart';
import 'package:movies/screens/favorites_page.dart';
import 'package:movies/screens/coming_soon_page.dart';
import 'package:movies/screens/settings_page.dart';
import 'package:movies/screens/support_page.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Movie>? discoverMovies;
  List<Movie>? trendingMovies;
  List<Movie>? currentGenreMovies;
  List<Movie>? continueWatching;
  List<Genres> genres = [];
  Movie? heroMovie;
  List<Video>? heroTrailers;
  String selectedGenre = 'Trending';
  bool isLoading = true;
  bool isLoadingGenre = false;
  String currentPage = 'Home';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    
    try {
      final genresList = await fetchGenres();
      final discover = await fetchMovies(Endpoints.discoverMoviesUrl(1));
      final trending = await fetchMovies(Endpoints.popularMoviesUrl(1));
      
      genres = genresList.genres ?? [];
      discoverMovies = discover;
      trendingMovies = trending;
      continueWatching = discover.take(3).toList();
      
      if (discover.isNotEmpty) {
        heroMovie = discover.first;
        final videos = await fetchVideos(heroMovie!.id!);
        heroTrailers = videos.results?.where((v) => 
          v.site == 'YouTube' && (v.type == 'Trailer' || v.type == 'Teaser')
        ).toList();
      }
      
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadGenreMovies(String genre) async {
    setState(() {
      selectedGenre = genre;
      isLoadingGenre = true;
    });
    
    if (genre == 'Trending') {
      setState(() {
        currentGenreMovies = null;
        isLoadingGenre = false;
      });
      return;
    }
    
    try {
      final genreObj = genres.firstWhere(
        (g) => g.name?.toLowerCase() == genre.toLowerCase(),
        orElse: () => Genres(id: 28, name: 'Action'),
      );
      
      final movies = await fetchMovies(Endpoints.getMoviesForGenre(genreObj.id ?? 28, 1));
      
      setState(() {
        currentGenreMovies = movies;
        isLoadingGenre = false;
      });
    } catch (e) {
      setState(() {
        isLoadingGenre = false;
      });
      print('Error loading genre movies: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F1419),
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(),
          
          // Main Content
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.amber))
                : Column(
                    children: [
                      _buildTopBar(),
                      Expanded(
                        child: _buildCurrentPage(),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (currentPage) {
      case 'Favorites':
        return FavoritesPage(genres: genres);
      case 'Coming soon':
        return ComingSoonPage(genres: genres);
      case 'Trending':
      case 'Home':
        return _buildHomePage();
      case 'Settings':
        return SettingsPage();
      case 'Support':
        return SupportPage();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroSection(),
          SizedBox(height: 30),
          _buildGenreTabs(),
          SizedBox(height: 20),
          _buildMovieGrid(),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: Color(0xFF1A1F26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.movie, color: Colors.amber, size: 28),
                SizedBox(width: 10),
                Text(
                  'Elijah',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildNavItem(Icons.home, 'Home', currentPage == 'Home'),
          _buildNavItem(Icons.favorite_outline, 'Favorites', currentPage == 'Favorites'),
          _buildNavItem(Icons.calendar_today, 'Coming soon', currentPage == 'Coming soon'),
          _buildNavItem(Icons.trending_up, 'Trending', currentPage == 'Trending'),
          Spacer(),
          _buildNavItem(Icons.settings, 'Settings', currentPage == 'Settings'),
          _buildNavItem(Icons.support_agent, 'Support', currentPage == 'Support'),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Continue Watching',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          _buildContinueWatchingSection(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: isActive ? Colors.white : Colors.white60, size: 20),
        title: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white60,
            fontSize: 14,
          ),
        ),
        dense: true,
        onTap: () {
          setState(() {
            currentPage = label;
            if (label == 'Home' || label == 'Trending') {
              selectedGenre = 'Trending';
            }
          });
        },
      ),
    );
  }

  Widget _buildContinueWatchingSection() {
    if (continueWatching == null || continueWatching!.isEmpty) {
      return SizedBox.shrink();
    }
    
    return Column(
      children: continueWatching!.take(2).map((movie) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailPage(
                  movie: movie,
                  themeData: Theme.of(context),
                  heroId: '${movie.id}continue',
                  genres: genres,
                ),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(TMDB_BASE_IMAGE_URL + 'w500/' + (movie.backdropPath ?? movie.posterPath ?? '')),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Icon(Icons.play_circle_outline, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie.title ?? '',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '55%',
                              style: TextStyle(color: Colors.white70, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 150,
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Color(0xFF1A1F26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: 'Movies',
              dropdownColor: Color(0xFF1A1F26),
              underline: SizedBox(),
              icon: Icon(Icons.arrow_drop_down, color: Colors.white),
              style: TextStyle(color: Colors.white),
              items: ['Movies', 'TV Shows'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (_) {},
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Color(0xFF1A1F26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Movies, series, shows...',
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.white38),
                ),
              ),
            ),
          ),
          SizedBox(width: 20),
          IconButton(
            icon: Icon(Icons.filter_alt_outlined, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          SizedBox(width: 10),
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.amber,
            child: Text('E', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    if (heroMovie == null) return SizedBox.shrink();
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(TMDB_BASE_IMAGE_URL + 'original/' + (heroMovie!.backdropPath ?? '')),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black87],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Wrap(
                spacing: 8,
                children: [
                  _buildPill('1h 55min'),
                  _buildPill('Action'),
                  _buildPill('Movie'),
                  _buildPill('2025'),
                  _buildPill('6+'),
                ],
              ),
              SizedBox(height: 60),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      if (heroTrailers != null && heroTrailers!.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TrailerPlayer(
                              videoKey: heroTrailers!.first.key!,
                              movieTitle: heroMovie!.title!,
                            ),
                          ),
                        );
                      }
                    },
                    icon: Icon(Icons.play_arrow, color: Colors.black),
                    label: Text('Play trailer · 2:30', style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  SizedBox(width: 12),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.favorite_border, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      padding: EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPill(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget _buildGenreTabs() {
    final genreNames = ['Trending', 'Adventure', 'Action', 'Comedy', 'Crime', 'Drama', 'Fantasy', 'Horror'];
    
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20),
        itemCount: genreNames.length,
        itemBuilder: (context, index) {
          final genre = genreNames[index];
          final isSelected = selectedGenre == genre;
          
          return GestureDetector(
            onTap: () => _loadGenreMovies(genre),
            child: Container(
              margin: EdgeInsets.only(right: 12),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.white30,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  genre,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMovieGrid() {
    if (isLoadingGenre) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(color: Colors.amber),
        ),
      );
    }
    
    final movies = selectedGenre == 'Trending' 
        ? trendingMovies 
        : currentGenreMovies;
    
    if (movies == null || movies.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'No movies found',
            style: TextStyle(color: Colors.white60),
          ),
        ),
      );
    }
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          childAspectRatio: 0.6,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return _buildMovieCard(movie);
        },
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
              heroId: '${movie.id}grid',
              genres: genres,
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
          SizedBox(height: 4),
          Row(
            children: [
              Text(
                movie.releaseDate?.split('-').first ?? '2024',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
              SizedBox(width: 8),
              Icon(Icons.star, color: Colors.amber, size: 14),
              SizedBox(width: 4),
              Text(
                movie.voteAverage ?? '0.0',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
