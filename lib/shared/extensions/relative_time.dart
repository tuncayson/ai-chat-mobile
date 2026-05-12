import 'package:intl/intl.dart';

extension RelativeTimeFormat on DateTime {
  /// "2m ago" / "3h ago" / "5d ago" / "Apr 15, 2026" depending on how long
  /// ago this `DateTime` was. Pass [now] in tests for deterministic output.
  String formatRelative({DateTime? now}) {
    final reference = now ?? DateTime.now();
    final diff = reference.difference(this);
    if (diff.isNegative || diff.inSeconds < 60) {
      return 'just now';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    return DateFormat.yMMMd().format(this);
  }
}
