import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/notifications/widgets/forms/notification_circle_item.dart';
import 'package:shiori/presentation/notifications/widgets/forms/notification_dropdown_type.dart';
import 'package:shiori/presentation/notifications/widgets/forms/notification_note.dart';
import 'package:shiori/presentation/notifications/widgets/forms/notification_switch.dart';
import 'package:shiori/presentation/notifications/widgets/forms/notification_title_body.dart';
import 'package:shiori/presentation/shared/dialogs/number_picker_dialog.dart';
import 'package:shiori/presentation/shared/dropdown_button_with_title.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/utils/enum_utils.dart';

const _type = AppNotificationType.realmCurrency;

class NotificationRealmCurrency extends StatelessWidget {
  final String title;
  final String body;
  final int currentRealmCurrency;
  final String note;
  final bool showNotification;
  final bool isInEditMode;
  final List<NotificationItemImage> images;
  final bool showOtherImages;
  final RealmRankType currentRankType;
  final int currentTrustRank;

  const NotificationRealmCurrency({
    super.key,
    required this.title,
    required this.body,
    required this.currentRealmCurrency,
    required this.note,
    required this.showNotification,
    required this.isInEditMode,
    required this.images,
    required this.showOtherImages,
    required this.currentRankType,
    required this.currentTrustRank,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        NotificationCircleItem(type: _type, images: images, showOtherImages: showOtherImages),
        Row(
          children: [
            Flexible(
              fit: FlexFit.tight,
              flex: 60,
              child: NotificationDropdownType(selectedValue: _type, isInEditMode: isInEditMode),
            ),
            const Spacer(flex: 10),
            Flexible(
              fit: FlexFit.tight,
              flex: 30,
              child: OutlinedButton(
                onPressed: () => _showRealmRankLevelPickerDialog(context),
                child: Text(s.currentX(currentRealmCurrency)),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              flex: 40,
              child: DropdownButtonWithTitle<RealmRankType>(
                title: s.realmRank,
                currentValue: currentRankType,
                items: EnumUtils.getTranslatedAndSortedEnum(
                  RealmRankType.values,
                  (val, index) => '# ${index + 1} - ${s.translateRealRankType(val)}',
                  sort: false,
                ),
                onChanged: (v) => context.read<NotificationBloc>().add(NotificationEvent.realmRankTypeChanged(newValue: v)),
              ),
            ),
            const Spacer(flex: 10),
            Expanded(
              flex: 40,
              child: DropdownButtonWithTitle<int>(
                title: s.trustRank,
                currentValue: currentTrustRank,
                items: realmTrustRank.keys.map((level) => TranslatedEnum<int>(level, '$level')).toList(),
                onChanged: (v) => context.read<NotificationBloc>().add(NotificationEvent.realmTrustRankLevelChanged(newValue: v)),
              ),
            ),
          ],
        ),
        NotificationTitleBody(title: title, body: body),
        NotificationNote(note: note),
        NotificationSwitch(showNotification: showNotification),
      ],
    );
  }

  Future<void> _showRealmRankLevelPickerDialog(BuildContext context) async {
    final s = S.of(context);
    final max = getRealmMaxCurrency(currentTrustRank);
    await showDialog<int>(
      context: context,
      builder: (_) => NumberPickerDialog(
        maxItemLevel: max - 1,
        minItemLevel: 0,
        value: currentRealmCurrency,
        title: s.realmCurrency,
      ),
    ).then((newValue) {
      if (newValue == null) {
        return;
      }

      context.read<NotificationBloc>().add(NotificationEvent.realmCurrencyChanged(newValue: newValue));
    });
  }
}
