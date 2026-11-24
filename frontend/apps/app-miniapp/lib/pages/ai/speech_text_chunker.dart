const _firstChunkLimit = 90;
const _followingChunkLimit = 220;

/// Splits spoken text into short sentence-aligned chunks so playback can begin
/// after the first chunk is synthesized instead of waiting for the full answer.
List<String> splitSpeechTextForPlayback(String text) {
  final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (normalized.isEmpty) {
    return const [];
  }

  final units = <String>[];
  final clauses = RegExp(
    r'[^。！？!?；;，,：:、]+[。！？!?；;，,：:、]*'
    r'|[。！？!?；;，,：:、]+',
  ).allMatches(normalized);
  for (final match in clauses) {
    final clause = match.group(0)?.trim();
    if (clause == null || clause.isEmpty) {
      continue;
    }
    units.addAll(_splitAtWhitespace(clause));
  }
  if (units.isEmpty) {
    units.add(normalized);
  }

  final chunks = <String>[];
  var current = '';
  for (final unit in units) {
    final limit = chunks.isEmpty ? _firstChunkLimit : _followingChunkLimit;
    if (current.isNotEmpty && current.length + unit.length > limit) {
      chunks.add(current.trim());
      current = unit;
    } else {
      current += unit;
    }
    if (current.length >= limit) {
      chunks.add(current.trim());
      current = '';
    }
  }
  if (current.trim().isNotEmpty) {
    chunks.add(current.trim());
  }
  return chunks;
}

List<String> _splitAtWhitespace(String text) {
  if (text.length <= _followingChunkLimit) {
    return [text];
  }
  final parts = <String>[];
  var remaining = text;
  while (remaining.length > _followingChunkLimit) {
    final window = remaining.substring(0, _followingChunkLimit);
    var splitAt = window.lastIndexOf(' ');
    if (splitAt < 0) {
      final nextSpace = remaining.indexOf(' ', _followingChunkLimit);
      if (nextSpace < 0) {
        break;
      }
      splitAt = nextSpace;
    }
    parts.add(remaining.substring(0, splitAt + 1));
    remaining = remaining.substring(splitAt + 1);
  }
  if (remaining.isNotEmpty) {
    parts.add(remaining);
  }
  return parts.isEmpty ? [text] : parts;
}
