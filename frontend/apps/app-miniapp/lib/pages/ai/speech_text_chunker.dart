const _firstChunkLimit = 90;
const _followingChunkLimit = 220;
const _streamingSoftBreakAfter = 12;
const _streamingMaxChunkLength = 64;

/// Returns the first safe cut in incrementally arriving answer text.
///
/// Hard punctuation always ends a segment. Soft punctuation is used once a
/// segment is long enough to sound natural, while unpunctuated text is capped
/// so auto-read can begin before the full answer has arrived.
int streamingSpeechCutIndex(String text) {
  const hardBreaks = '。！？!?；;\n';
  const softBreaks = '，,、：:';
  final limit = text.length < _streamingMaxChunkLength
      ? text.length
      : _streamingMaxChunkLength;
  for (var index = 0; index < limit; index++) {
    final char = text[index];
    if (hardBreaks.contains(char)) {
      return index + 1;
    }
    if (softBreaks.contains(char)) {
      if (index + 1 >= _streamingSoftBreakAfter) {
        return index + 1;
      }
    }
  }
  if (text.length < _streamingMaxChunkLength) {
    return -1;
  }
  final whitespace = text.lastIndexOf(' ', _streamingMaxChunkLength);
  return whitespace > 0 ? whitespace + 1 : _streamingMaxChunkLength;
}

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
