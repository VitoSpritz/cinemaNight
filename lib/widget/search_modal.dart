import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../consts/custom_colors.dart';
import '../consts/custom_typography.dart';
import '../helpers/app_palette.dart';

class SearchModal extends ConsumerWidget {
  final String title;
  const SearchModal({super.key, required this.title});

  static Future<String?> show({
    required BuildContext context,
    required String title,
    Future<void> Function()? function,
  }) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SearchModal(title: title);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController searchController = TextEditingController();
    return AlertDialog(
      alignment: Alignment.topCenter,
      scrollable: true,
      backgroundColor: CustomColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => context.pop(searchController.text),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Icon(
                      Icons.close,
                      fill: 0,
                      color: AppPalette.of(context).textColors.simpleText,
                    ),
                  ),
                ),
              ],
            ),
            Flexible(
              child: Text(
                title,
                style: CustomTypography.titleM.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppPalette.of(context).textColors.simpleText,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.search,
                    color: CustomColors.lightBlue,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(),
                  ),
                ),
                style: CustomTypography.body.copyWith(
                  color: AppPalette.of(context).textColors.simpleText,
                ),
                onTapOutside: (PointerDownEvent event) {
                  if (searchController.text.isNotEmpty &&
                      searchController.text.trim().isNotEmpty) {
                    context.pop(searchController.text);
                  }
                },
                onSubmitted: (String value) {
                  if (searchController.text.isNotEmpty &&
                      searchController.text.trim().isNotEmpty) {
                    context.pop(searchController.text);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
