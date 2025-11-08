import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../consts/sizes.dart';
import '../l10n/app_localizations.dart';
import '../model/media.dart';
import '../model/movie.dart';
import '../model/multi_with_poster.dart';
import '../model/review.dart';
import '../model/tv_show.dart';
import '../model/user_profile.dart';
import '../providers/tmdb_api.dart';
import '../providers/user_profiles.dart';
import '../providers/user_review.dart';
import '../services/review_service.dart';
import 'custom_movie_display.dart';
import 'custom_rating.dart';

class FilmPickerModal extends ConsumerStatefulWidget {
  const FilmPickerModal({super.key});

  @override
  ConsumerState<FilmPickerModal> createState() => _FilmPickerState();
}

class _FilmPickerState extends ConsumerState<FilmPickerModal> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();

  final TmdbApi _tmdbApi = TmdbApi();
  List<MultiWithPoster> _searchResults = <MultiWithPoster>[];
  bool _isLoading = false;
  bool _isCreatingReview = false;
  MultiWithPoster? _selectedMedia;
  final ReviewService _reviewService = ReviewService();
  int _currentPage = 1;
  int _totalPages = 1;
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _scrollController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final double maxScroll = _scrollController.position.maxScrollExtent;
    final double currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll - 300 && !_isLoadingMore) {
      _loadNextPage();
    }
  }

  Future<void> _loadNextPage() async {
    if (_currentPage >= _totalPages || _isLoadingMore) {
      return;
    }

    setState(() => _isLoadingMore = true);

    try {
      final List<MultiWithPoster> results = await _tmdbApi
          .getMultiMediaWithPosters(
            name: _titleController.text,
            language: AppLocalizations.of(context)!.requestApiLanguage,
            page: _currentPage + 1,
          );

      setState(() {
        _searchResults.addAll(results);
        _currentPage++;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading more: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _createReview({
    required int filmId,
    required String type,
    String? review,
    double? rating,
  }) async {
    setState(() {
      _isCreatingReview = true;
    });

    try {
      final UserProfile userProfile = await ref.read(
        userProfilesProvider.future,
      );
      final AsyncValue<List<Review>> userReview = ref.read(userReviewProvider);

      if (userReview.value?.any(
            (Review element) => element.filmId == filmId.toString(),
          ) ==
          true) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Film already exists")));
        }
      }

      await _reviewService.createReview(
        userId: userProfile.userId,
        filmId: filmId.toString(),
        type: type == "movie" ? ReviewItemType.movie : ReviewItemType.tvSeries,
        description: review,
        rating: rating,
      );
      if (mounted) {
        Navigator.pop(context);
      }
      ref.invalidate(userReviewProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error $e")));
      }
    }

    setState(() {
      _isCreatingReview = false;
    });
  }

  Future<void> _searchMedia() async {
    final String value = _titleController.text;
    if (value.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
      _searchResults = <MultiWithPoster>[];
      _currentPage = 1;
    });

    try {
      final List<MultiWithPoster> results = await _tmdbApi
          .getMultiMediaWithPosters(
            name: value,
            language: AppLocalizations.of(context)!.requestApiLanguage,
            page: 1,
          );

      setState(() {
        _searchResults = results;
        _isLoading = false;
        _totalPages = 10;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              AppLocalizations.of(context)!.addReview,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (_selectedMedia == null) ...<Widget>[
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.title,
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.search, size: Sizes.iconSize),
                ),
                onSubmitted: (_) => _searchMedia(),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _searchMedia,
                  child: Text(AppLocalizations.of(context)!.search),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_selectedMedia == null && _searchResults.isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      AppLocalizations.of(context)!.results,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount:
                            _searchResults.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (BuildContext context, int index) {
                          if (index == _searchResults.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final MultiWithPoster item = _searchResults[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedMedia = item);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: CustomMovieDisplay(
                                imageUrl: item.posterBytes,
                                movieTitle: item.media.when(
                                  movie: (Movie movie) => movie.title,
                                  tvSeries: (TvShow tvSeries) => tvSeries.name,
                                ),
                                rating: item.media.when(
                                  movie: (Movie movie) => movie.voteAverage,
                                  tvSeries: (TvShow tvSeries) =>
                                      tvSeries.voteAverage,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
            else if (_selectedMedia == null)
              Expanded(
                child: Center(
                  child: Text(AppLocalizations.of(context)!.searchAMovie),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  children: <Widget>[
                    CustomMovieDisplay(
                      imageUrl: _selectedMedia!.posterBytes,
                      movieTitle: _selectedMedia!.media.when(
                        movie: (Movie movie) => movie.title,
                        tvSeries: (TvShow tvSeries) => tvSeries.name,
                      ),
                      rating: _selectedMedia!.media.when(
                        movie: (Movie movie) => movie.voteAverage,
                        tvSeries: (TvShow tvSeries) => tvSeries.voteAverage,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedMedia = null;
                          _searchResults = <MultiWithPoster>[];
                          _titleController.clear();
                        });
                      },
                      child: Text(AppLocalizations.of(context)!.changeMovie),
                    ),
                    Row(
                      children: <Widget>[
                        const Text("Il tuo voto:"),
                        CustomRating(
                          onRatingChanged: (double rating) {
                            _ratingController.text = rating.toString();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _reviewController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.review,
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: _isCreatingReview
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: () async => await _createReview(
                                filmId: _selectedMedia!.media.when(
                                  movie: (Movie movie) => movie.id,
                                  tvSeries: (TvShow tvSeries) => tvSeries.id,
                                ),
                                type: _selectedMedia!.media.when(
                                  movie: (Movie movie) =>
                                      ReviewItemType.movie.name,
                                  tvSeries: (TvShow tvSeries) =>
                                      ReviewItemType.tvSeries.name,
                                ),
                                review: _reviewController.text,
                                rating: double.parse(_ratingController.text),
                              ),
                              child: Text(AppLocalizations.of(context)!.save),
                            ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
