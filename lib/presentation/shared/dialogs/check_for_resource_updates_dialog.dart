import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';

class CheckForResourceUpdatesDialog extends StatelessWidget {
  const CheckForResourceUpdatesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return BlocProvider<CheckForResourceUpdatesBloc>(
      create: (context) => Injection.checkForResourceUpdatesBlocBloc..add(const CheckForResourceUpdatesEvent.init()),
      child: BlocBuilder<CheckForResourceUpdatesBloc, CheckForResourceUpdatesState>(
        builder: (context, state) => state.maybeMap(
          loaded: (state) => AlertDialog(
            title: Text(s.checkForResourceUpdates),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.updateResultType != null) Text(_getMsgToShow(state.updateResultType!, s)),
                if (state.updateResultType != null) SizedBox.fromSize(size: const Size(10, 10)),
                Text(s.currentResourcesVersion(state.currentResourceVersion)),
                if (state.targetResourceVersion != null) Text(s.newResourcesVersion(state.targetResourceVersion!)),
              ],
            ),
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(s.cancel, style: TextStyle(color: theme.primaryColor)),
              ),
              ElevatedButton(
                onPressed: () => context.read<CheckForResourceUpdatesBloc>().add(const CheckForResourceUpdatesEvent.checkForUpdates()),
                child: Text(s.check),
              ),
              if (state.updateResultType == AppResourceUpdateResultType.updatesAvailable)
                ElevatedButton(
                  onPressed: () => context.read<MainBloc>().add(const MainEvent.restart()),
                  child: Text(s.applyUpdate),
                ),
            ],
          ),
          orElse: () => AlertDialog(
            title: Text(s.checkForResourceUpdates),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(s.checkingForResourceUpdates),
                LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  backgroundColor: Colors.transparent,
                ),
              ],
            ),
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(s.cancel, style: TextStyle(color: theme.primaryColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMsgToShow(AppResourceUpdateResultType resultType, S s) {
    switch (resultType) {
      case AppResourceUpdateResultType.unknownError:
      case AppResourceUpdateResultType.unknownErrorOnFirstInstall:
        return s.unknownError;
      case AppResourceUpdateResultType.apiIsUnavailable:
      case AppResourceUpdateResultType.noUpdatesAvailable:
        return '${s.noUpdatesAvailable}\n${s.tryAgainLater}';
      case AppResourceUpdateResultType.needsLatestAppVersion:
        return s.newAppVersionInStore;
      case AppResourceUpdateResultType.updatesAvailable:
        return s.updatesAvailable;
      case AppResourceUpdateResultType.noInternetConnection:
        return s.noInternetConnection;
      //below ones should not be shown in this dialog
      case AppResourceUpdateResultType.noInternetConnectionForFirstInstall:
      case AppResourceUpdateResultType.retrying:
      case AppResourceUpdateResultType.updated:
      case AppResourceUpdateResultType.updating:
        return s.na;
    }
  }
}
