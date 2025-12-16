import 'package:flutter/material.dart';

import '../consts/custom_colors.dart';
import '../consts/custom_typography.dart';
import '../consts/sizes.dart';
import '../helpers/media_converter.dart';
import '../l10n/app_localizations.dart';
import '../model/media.dart';
import '../model/multi_with_poster.dart';
import '../providers/tmdb_api.dart';
import 'custom_movie_display.dart';

class FilmSuggestionModal extends StatefulWidget {
  const FilmSuggestionModal({super.key});

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => const FilmSuggestionModal(),
    );
  }

  @override
  State<FilmSuggestionModal> createState() => _FilmSuggestionModalState();
}

class _FilmSuggestionModalState extends State<FilmSuggestionModal> {
  final TextEditingController _titleController = TextEditingController();
  final TmdbApi _tmdbApi = TmdbApi();
  List<MultiWithPoster> _searchResults = <MultiWithPoster>[];
  bool _isLoading = false;
  MultiWithPoster? _selectedMedia;
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
            name: _titleController.text.toLowerCase(),
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
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              )!.filmSuggestionModalLoadingMoreError(e.toString()),
            ),
          ),
        );
      }
    }
  }

  void _confirmSelection() {
    if (_selectedMedia == null) {
      return;
    }

    Navigator.pop(
      context,
      MediaConverter.getValue(
        media: _selectedMedia!.media,
        field: MediaField.title,
      ).toString(),
    );
  }

  Future<void> _searchMedia() async {
    final String value = _titleController.text.toLowerCase();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              )!.filmSuggestionModalError(e.toString()),
            ),
          ),
        );
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
              AppLocalizations.of(context)!.filmSuggestionModalSuggetFilm,
              style: CustomTypography.titleM.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            if (_selectedMedia == null) ...<Widget>[
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.title,
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.search, size: Sizes.iconMedium),
                ),
                onSubmitted: (_) => _searchMedia(),
              ),
              const SizedBox(height: 16),
              Center(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                    ),
                    backgroundColor: CustomColors.white,
                  ),
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
                      style: CustomTypography.bodyBold,
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
                                movieTitle: MediaConverter.getValue(
                                  media: item.media,
                                  field: MediaField.title,
                                ),
                                rating: MediaConverter.getValue(
                                  media: item.media,
                                  field: MediaField.rating,
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
                      movieTitle: MediaConverter.getValue(
                        media: _selectedMedia!.media,
                        field: MediaField.title,
                      ),
                      rating: MediaConverter.getValue(
                        media: _selectedMedia!.media,
                        field: MediaField.rating,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18)),
                          ),
                          backgroundColor: CustomColors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedMedia = null;
                            _searchResults = <MultiWithPoster>[];
                            _titleController.clear();
                          });
                        },
                        child: Text(AppLocalizations.of(context)!.changeMovie),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18)),
                          ),
                          backgroundColor: CustomColors.mainYellow,
                        ),
                        onPressed: _confirmSelection,
                        child: Text(AppLocalizations.of(context)!.confirmLabel),
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
