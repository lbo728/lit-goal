class DateUtils {
  static int getDaysBetween(DateTime startDate, DateTime endDate) {
    return endDate.difference(startDate).inDays;
  }

  static double getProgressPercentage(DateTime startDate, DateTime endDate) {
    final now = DateTime.now();
    final totalDays = getDaysBetween(startDate, endDate);
    final passedDays = getDaysBetween(startDate, now);

    if (totalDays <= 0) return 0.0;
    return (passedDays / totalDays * 100).clamp(0.0, 100.0);
  }

  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String getDateDifference(DateTime targetDate) {
    final now = DateTime.now();
    final difference = targetDate.difference(now).inDays;

    if (difference > 0) {
      return 'D-$difference';
    } else if (difference == 0) {
      return 'D-Day';
    } else {
      return 'D+${difference.abs()}';
    }
  }
}
