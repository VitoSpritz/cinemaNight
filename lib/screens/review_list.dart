import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../model/media_with_poster.dart';
import '../providers/tmdb_api.dart';
import '../widget/custom_add_button.dart';
import '../widget/custom_app_bar.dart';
import '../widget/custom_movie_display.dart';

class ReviewList extends StatelessWidget {
  static String path = '/reviewList';

  const ReviewList({super.key});

  void _showModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return const _ModalContent();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.reviews,
        searchEnabled: true,
      ),
      body: Center(child: Text(AppLocalizations.of(context)!.noReviews)),
      floatingActionButton: CustomAddButton(
        onPressed: () => _showModal(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _ModalContent extends StatefulWidget {
  const _ModalContent();

  @override
  State<_ModalContent> createState() => _ModalContentState();
}

class _ModalContentState extends State<_ModalContent> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController reviewController = TextEditingController();
  final TmdbApi tmdbApi = TmdbApi();
  List<MediaWithPoster> searchResults = <MediaWithPoster>[];
  bool isLoading = false;
  MediaWithPoster? selectedMedia;

  @override
  void dispose() {
    titleController.dispose();
    reviewController.dispose();
    super.dispose();
  }

  Future<void> _searchMedia() async {
    final String value = titleController.text;
    if (value.isEmpty) {
      return;
    }

    setState(() {
      isLoading = true;
      searchResults = <MediaWithPoster>[];
    });

    try {
      final List<MediaWithPoster> results = await tmdbApi
          .getMultiMediaWithPosters(
            name: value,
            language: AppLocalizations.of(context)!.requestApiLanguage,
          );

      setState(() {
        searchResults = results.take(5).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('Errore durante la ricerca: $e');
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

            if (selectedMedia == null) ...<Widget>[
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.title,
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.search),
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

            if (isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (selectedMedia == null && searchResults.isNotEmpty)
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
                        itemCount: searchResults.length,
                        itemBuilder: (BuildContext context, int index) {
                          final MediaWithPoster item = searchResults[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() => selectedMedia = item);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: CustomMovieDisplay(
                                imageUrl: item.posterBytes,
                                movieTitle: item.media.title,
                                rating: null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
            else if (selectedMedia == null)
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
                      imageUrl: selectedMedia!.posterBytes,
                      movieTitle: selectedMedia!.media.title,
                      rating: null,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedMedia = null;
                          searchResults = <MediaWithPoster>[];
                          titleController.clear();
                        });
                      },
                      child: Text(AppLocalizations.of(context)!.changeMovie),
                    ),
                    TextField(
                      controller: reviewController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.review,
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
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
