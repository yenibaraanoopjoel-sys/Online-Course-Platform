import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppDateUtils {
  AppDateUtils._();

  static String formatDate(DateTime dt) => DateFormat('MMM d, yyyy').format(dt);

  static String formatDateTime(DateTime dt) =>
      DateFormat('MMM d, yyyy • h:mm a').format(dt);

  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  static DateTime fromTimestamp(dynamic ts) {
    if (ts is Timestamp) return ts.toDate();
    if (ts is DateTime) return ts;
    return DateTime.now();
  }

  static Timestamp toTimestamp(DateTime dt) => Timestamp.fromDate(dt);
}
