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

class FilmPickerModal extends ConsumerStatefulWidget {
  const FilmPickerModal({super.key});

  @override
  ConsumerState<FilmPickerModal> createState() => _FilmPickerState();
}

class _FilmPickerState extends ConsumerState<FilmPickerModal> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  final TmdbApi _tmdbApi = TmdbApi();
  List<MultiWithPoster> _searchResults = <MultiWithPoster>[];
  bool _isLoading = false;
  bool _isCreatingReview = false;
  MultiWithPoster? _selectedMedia;
  final ReviewService _reviewService = ReviewService();

  @override
  void dispose() {
    _titleController.dispose();
    _reviewController.dispose();
    super.dispose();
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
    });

    try {
      final List<MultiWithPoster> results = await _tmdbApi
          .getMultiMediaWithPosters(
            name: value,
            language: AppLocalizations.of(context)!.requestApiLanguage,
          );

      setState(() {
        _searchResults = results.take(5).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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
                        itemCount: _searchResults.length,
                        itemBuilder: (BuildContext context, int index) {
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
                                review: _reviewController.text ?? "No review",
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
