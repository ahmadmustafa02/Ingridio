Duration? parseDurationFromStepText(String text) {
  final String lower = text.toLowerCase();
  final RegExp reg = RegExp(
    r'(\d+)\s*(hours?|hrs?|hr|minutes?|mins?|min|seconds?|secs?|sec)\b',
    caseSensitive: false,
  );
  final RegExpMatch? m = reg.firstMatch(lower);
  if (m == null) {
    return null;
  }
  final int n = int.parse(m.group(1)!);
  final String u = m.group(2)!.toLowerCase();
  if (u.startsWith('hour') || u == 'hr') {
    return Duration(hours: n);
  }
  if (u.startsWith('sec')) {
    return Duration(seconds: n);
  }
  return Duration(minutes: n);
}

bool stepTextSuggestsTimer(String text) {
  final String lower = text.toLowerCase();
  return lower.contains('min') ||
      lower.contains('minute') ||
      lower.contains('hour') ||
      lower.contains('sec') ||
      lower.contains('second');
}
