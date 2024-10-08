//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Dart/Flutter (DF) Packages by DevCetra.com & contributors. The use of this
// source code is governed by an MIT-style license described in the LICENSE
// file located in this project's root directory.
//
// See: https://opensource.org/license/mit
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

import 'dart:async';

import 'core_utils_on_lang_x.dart';

import 'io.dart';
import 'lang.dart';
import 'paths.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Finds all source file paths in [rootDirPath] that for the given [lang].
///
/// If [pathPatterns] is specified, only file paths that match all
/// [pathPatterns] are added to the results.
///
/// The [onFileFound] callback is invoked for each file, allowing for custom
/// filtering, i.e. if the it returns `true`, the file is added, if it returns
/// `false`, the file is not added.
Future<List<String>> findSourceFilePaths(
  String rootDirPath, {
  required Lang lang,
  Set<String> pathPatterns = const {},
  FutureOr<bool> Function(String filePath)? onFileFound,
}) async {
  return findFilePaths(
    rootDirPath,
    pathPatterns: pathPatterns,
    recursive: true,
    onFilePathFound: (result) async {
      final a = await onFileFound?.call(result) ?? true;
      final b = lang.isValidSrcFilePath(result);
      return a && b;
    },
  );
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Finds all generated file paths in [rootDirPath] that for the given [lang].
///
/// If [pathPatterns] is specified, only file paths that match all
/// [pathPatterns] are added to the results.
///
/// The [onFileFound] callback is invoked for each file, allowing for custom
/// filtering, i.e. if the it returns `true`, the file is added, if it returns
/// `false`, the file is not added.
Future<List<String>> findGeneratedFilePaths(
  String rootDirPath, {
  required Lang lang,
  Set<String> pathPatterns = const {},
  FutureOr<bool> Function(String filePath)? onFileFound,
}) async {
  return findFilePaths(
    rootDirPath,
    pathPatterns: pathPatterns,
    recursive: true,
    onFilePathFound: (result) async {
      final a = await onFileFound?.call(result) ?? true;
      final b = lang.isValidGenFilePath(result);
      return a && b;
    },
  );
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Finds all files in [rootDirPath], including sub-directories if [recursive]
/// is `true`.
///
/// The [onFilePathFound] callback is invoked for each file, allowing for custom
/// filtering, i.e. if the it returns `true`, the file is added, if it returns
/// `false`, the file is not added.
Future<List<String>> findFilePaths(
  String rootDirPath, {
  Set<String> pathPatterns = const {},
  bool recursive = true,
  FutureOr<bool> Function(String filePath)? onFilePathFound,
}) async {
  final results = <String>[];
  final filePaths = await listFilePaths(
    rootDirPath,
    recursive: recursive,
  );
  if (filePaths != null) {
    filePaths.sort();
    for (final filePath in filePaths) {
      final a = matchesAnyPathPattern(filePath, pathPatterns);
      if (!a) continue;

      final b = (await onFilePathFound?.call(filePath)) ?? true;
      if (!b) continue;
      results.add(filePath);
    }
  }
  return results;
}
