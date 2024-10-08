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

/// Filters [dirPaths] by extracting only the topmost directory paths. Use
/// [toPath] to specify how to map [T] to the path String.
List<T> extractTopmostDirPaths<T>(
  Iterable<T> dirPaths, {
  required String Function(T) toPath,
}) {
  final dirPaths1 = dirPaths.toList();
  dirPaths1.sort((a, b) => toPath(a).length.compareTo(toPath(b).length));
  final topmostResults = <T>[];
  for (final result in dirPaths1) {
    if (topmostResults.every(
      (topmostResult) =>
          !toPath(result).startsWith('${toPath(topmostResult)}/'),
    )) {
      topmostResults.add(result);
    }
  }

  return topmostResults;
}
