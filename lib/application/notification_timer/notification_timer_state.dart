part of 'notification_timer_bloc.dart';

@freezed
class NotificationTimerState with _$NotificationTimerState {
  const factory NotificationTimerState.loaded({
    required DateTime completesAt,
    required Duration remaining,
  }) = _LoadedState;
}
