import 'dart:io';
import 'dart:typed_data';

class DeepSeekTtsCache {
  DeepSeekTtsCache({
    Directory? directory,
    this.maxFiles = 20,
    this.maxBytes = 100 * 1024 * 1024,
  }) : _directory =
           directory ??
           Directory('${Directory.systemTemp.path}/ruoqi_tts_cache');

  final Directory _directory;
  final int maxFiles;
  final int maxBytes;

  Future<File?> get({
    required String text,
    String voiceId = 'stella',
    String format = 'wav',
    bool filterMarkdown = true,
  }) async {
    final file = _fileFor(
      text: text,
      voiceId: voiceId,
      format: format,
      filterMarkdown: filterMarkdown,
    );
    if (!await file.exists()) {
      return null;
    }
    if (await file.length() == 0) {
      await file.delete();
      return null;
    }
    await file.setLastModified(DateTime.now());
    return file;
  }

  Future<File> put({
    required String text,
    required Uint8List bytes,
    String voiceId = 'stella',
    String format = 'wav',
    bool filterMarkdown = true,
  }) async {
    await _directory.create(recursive: true);
    final file = _fileFor(
      text: text,
      voiceId: voiceId,
      format: format,
      filterMarkdown: filterMarkdown,
    );
    await file.writeAsBytes(bytes, flush: true);
    await prune();
    return file;
  }

  Future<void> prune() async {
    if (!await _directory.exists()) {
      return;
    }
    final files = await _directory
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.wav'))
        .cast<File>()
        .toList();
    final entries = <({File file, int size, DateTime modified})>[];
    for (final file in files) {
      entries.add((
        file: file,
        size: await file.length(),
        modified: await file.lastModified(),
      ));
    }
    entries.sort((a, b) => b.modified.compareTo(a.modified));
    var retainedBytes = 0;
    for (var index = 0; index < entries.length; index++) {
      final entry = entries[index];
      retainedBytes += entry.size;
      if (index >= maxFiles || retainedBytes > maxBytes) {
        await entry.file.delete();
      }
    }
  }

  File _fileFor({
    required String text,
    required String voiceId,
    required String format,
    required bool filterMarkdown,
  }) {
    final key = _fnv1a64('$voiceId|$format|$filterMarkdown|$text')
        .toRadixString(16)
        .padLeft(16, '0');
    return File('${_directory.path}/$key.$format');
  }
}

int _fnv1a64(String value) {
  var hash = 0xcbf29ce484222325;
  for (final codeUnit in value.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
  }
  return hash;
}
