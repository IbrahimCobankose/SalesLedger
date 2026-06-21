import 'package:flutter/widgets.dart';
import 'package:sales_ledger/core/l10n/gen/app_localizations.dart';

/// `context.l10n.key` kısayolu — her yerde `AppLocalizations.of(context)!`
/// yazmak yerine kullanılır.
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
