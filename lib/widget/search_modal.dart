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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: CustomTypography.titleXL.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppPalette.of(context).textColors.simpleText,
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => context.pop(searchController.text),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.close, fill: 0),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(style: BorderStyle.solid),
                  borderRadius: const BorderRadius.all(Radius.circular(24)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.search, color: CustomColors.lightBlue),
                      border: InputBorder.none,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
