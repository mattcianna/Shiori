import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/custom_build/widgets/artifact_section.dart';
import 'package:shiori/presentation/custom_build/widgets/character_section.dart';
import 'package:shiori/presentation/custom_build/widgets/team_section.dart';
import 'package:shiori/presentation/custom_build/widgets/weapon_section.dart';
import 'package:shiori/presentation/shared/dialogs/confirm_dialog.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/toast_utils.dart';

const double _maxItemImageWidth = 130;

class CustomBuildPage extends StatefulWidget {
  final int? itemKey;

  const CustomBuildPage({
    Key? key,
    this.itemKey,
  }) : super(key: key);

  @override
  State<CustomBuildPage> createState() => _CustomBuildPageState();
}

class _CustomBuildPageState extends State<CustomBuildPage> {
  final _screenshotController = ScreenshotController();

  bool get newBuild => widget.itemKey == null;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final width = MediaQuery.of(context).size.width;
    return BlocProvider(
      create: (ctx) => Injection.getCustomBuildBloc(context.read<CustomBuildsBloc>())
        ..add(
          CustomBuildEvent.load(key: widget.itemKey, initialTitle: s.dps),
        ),
      child: Scaffold(
        appBar: _AppBar(
          newBuild: newBuild,
          screenshotController: _screenshotController,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 10),
          child: Screenshot(
            controller: _screenshotController,
            child: OrientationLayoutBuilder(
              portrait: (context) => const _PortraitLayout(),
              landscape: (context) => width > 1280 ? const _LandscapeLayout() : const _PortraitLayout(),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool newBuild;
  final ScreenshotController screenshotController;

  const _AppBar({
    Key? key,
    required this.newBuild,
    required this.screenshotController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return BlocBuilder<CustomBuildBloc, CustomBuildState>(
      builder: (ctx, state) => state.maybeMap(
        loaded: (state) => AppBar(
          title: Text(newBuild ? s.add : s.edit),
          actions: [
            if (!state.readyForScreenshot)
              Tooltip(
                message: s.save,
                child: IconButton(
                  splashRadius: Styles.mediumButtonSplashRadius,
                  icon: const Icon(Icons.save),
                  onPressed: !(state.artifacts.length == ArtifactType.values.length && state.weapons.isNotEmpty) ? null : () => _saveChanges(context),
                ),
              ),
            if (state.readyForScreenshot)
              Tooltip(
                message: s.save,
                child: IconButton(
                  splashRadius: Styles.mediumButtonSplashRadius,
                  icon: const Icon(Icons.save_alt),
                  onPressed: () => _takeScreenshot(context),
                ),
              ),
            if (state.readyForScreenshot)
              Tooltip(
                message: s.cancel,
                child: IconButton(
                  splashRadius: Styles.mediumButtonSplashRadius,
                  icon: const Icon(Icons.undo),
                  onPressed: () => context.read<CustomBuildBloc>().add(const CustomBuildEvent.readyForScreenshot(ready: false)),
                ),
              ),
            if (!newBuild && state.key != null && !state.readyForScreenshot)
              Tooltip(
                message: s.delete,
                child: IconButton(
                  splashRadius: Styles.mediumButtonSplashRadius,
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteDialog(context, state.key),
                ),
              ),
            if (!state.readyForScreenshot)
              PopupMenuButton<int>(
                onSelected: (e) {
                  switch (e) {
                    case 0:
                      context.read<CustomBuildBloc>().add(CustomBuildEvent.showOnCharacterDetailChanged(newValue: !state.showOnCharacterDetail));
                      break;
                    default:
                      throw Exception('Invalid option');
                  }
                },
                tooltip: s.options,
                itemBuilder: (BuildContext context) {
                  return [0].map((int choice) {
                    switch (choice) {
                      case 0:
                        return PopupMenuItem<int>(
                          value: choice,
                          child: ListTile(
                            title: Text(s.showOnCharacterDetail),
                            leading: Icon(
                              state.showOnCharacterDetail ? Icons.check_box : Icons.check_box_outline_blank,
                              color: theme.brightness == Brightness.dark
                                  ? state.character.elementType.getElementColorFromContext(context)
                                  : theme.colorScheme.secondary,
                            ),
                          ),
                        );
                      default:
                        throw Exception('Invalid option');
                    }
                  }).toList();
                },
              ),
          ],
        ),
        orElse: () => AppBar(
          title: Text(newBuild ? s.add : s.edit),
        ),
      ),
    );
  }

  void _saveChanges(BuildContext context) {
    final s = S.of(context);
    context.read<CustomBuildBloc>().add(const CustomBuildEvent.saveChanges());
    ToastUtils.showSucceedToast(ToastUtils.of(context), s.changeWereSuccessfullySaved);
  }

  Future<void> _takeScreenshot(BuildContext context) async {
    final s = S.of(context);
    final fToast = ToastUtils.of(context);
    final bloc = context.read<CustomBuildBloc>();
    try {
      if (!await Permission.storage.request().isGranted) {
        ToastUtils.showInfoToast(fToast, s.acceptToSaveImg);
        return;
      }

      final bytes = await screenshotController.capture(pixelRatio: 1.5);
      await ImageGallerySaver.saveImage(bytes!, quality: 100);
      ToastUtils.showSucceedToast(fToast, s.imgSavedSuccessfully);
      bloc.add(const CustomBuildEvent.screenshotWasTaken(succeed: true));
    } catch (e, trace) {
      ToastUtils.showErrorToast(fToast, s.unknownError);
      bloc.add(CustomBuildEvent.screenshotWasTaken(succeed: false, ex: e, trace: trace));
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, int? buildKey) {
    final s = S.of(context);
    return showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: s.delete,
        content: s.confirmQuestion,
        onOk: () {
          context.read<CustomBuildsBloc>().add(CustomBuildsEvent.delete(key: buildKey!));
        },
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _PortraitLayout extends StatelessWidget {
  const _PortraitLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CharacterSection(),
        ScreenTypeLayout.builder(
          desktop: (context) => const _WeaponsAndArtifacts(),
          tablet: (context) => const _WeaponsAndArtifacts(),
          mobile: (context) => _WeaponsAndArtifacts(
            useColumn: isPortrait,
          ),
        ),
      ],
    );
  }
}

class _LandscapeLayout extends StatelessWidget {
  const _LandscapeLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          flex: 40,
          child: CharacterSection(),
        ),
        Expanded(
          flex: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(
                child: WeaponSection(
                  maxItemImageWidth: _maxItemImageWidth,
                  useBoxDecoration: false,
                ),
              ),
              Expanded(
                child: ArtifactSection(
                  maxItemImageWidth: _maxItemImageWidth,
                  useBoxDecoration: false,
                ),
              ),
              Expanded(
                child: TeamSection(useBoxDecoration: false),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeaponsAndArtifacts extends StatelessWidget {
  final bool useColumn;

  const _WeaponsAndArtifacts({
    Key? key,
    this.useColumn = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (useColumn) {
      return Column(
        children: const [
          WeaponSection(
            maxItemImageWidth: _maxItemImageWidth,
            useBoxDecoration: true,
          ),
          ArtifactSection(
            maxItemImageWidth: _maxItemImageWidth,
            useBoxDecoration: true,
          ),
          TeamSection(useBoxDecoration: true),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Expanded(
              child: WeaponSection(
                maxItemImageWidth: _maxItemImageWidth,
                useBoxDecoration: true,
              ),
            ),
            Expanded(
              child: ArtifactSection(
                maxItemImageWidth: _maxItemImageWidth,
                useBoxDecoration: true,
              ),
            ),
          ],
        ),
        const TeamSection(useBoxDecoration: true),
      ],
    );
  }
}
