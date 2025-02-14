import 'package:flutter/material.dart';
import 'package:shiori/presentation/shared/images/element_image.dart';
import 'package:shiori/presentation/shared/styles.dart';

class ElementReactionCard extends StatelessWidget {
  final String name;
  final String effect;
  final List<String> principal;
  final List<String> secondary;
  final bool showPlusIcon;
  final bool showImages;
  final String? description;

  const ElementReactionCard.withImages({
    super.key,
    required this.name,
    required this.effect,
    required this.principal,
    required this.secondary,
    this.showPlusIcon = true,
  })  : showImages = true,
        description = null;

  const ElementReactionCard.withoutImage({
    super.key,
    required this.name,
    required this.effect,
    required this.description,
    this.showPlusIcon = true,
  })  : principal = const [],
        secondary = const [],
        showImages = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final principalImgs = principal.map((e) => ElementImage.fromPath(path: e)).toList();
    final secondaryImgs = secondary.map((e) => ElementImage.fromPath(path: e)).toList();
    return Card(
      shape: Styles.cardShape,
      margin: Styles.edgeInsetAll5,
      child: Padding(
        padding: Styles.edgeInsetAll5,
        child: Column(
          children: [
            if (showImages)
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                children: [
                  ...principalImgs,
                  if (showPlusIcon) const Icon(Icons.add),
                  ...secondaryImgs,
                ],
              ),
            if (!showImages)
              Text(
                description!,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
              ),
            Text(
              name,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              effect,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall!.copyWith(fontSize: 12),
            )
          ],
        ),
      ),
    );
  }
}
