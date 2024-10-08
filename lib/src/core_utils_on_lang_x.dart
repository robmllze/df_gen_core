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

import 'package:df_string/df_string.dart';
import 'package:path/path.dart' as p;

import 'io.dart';
import 'lang.dart';
import 'paths.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension CoreUtilsOnXyzGenLangX on Lang {
  //
  //
  //

  /// The file extension associated with the language, e.g. '.dart'.
  String get srcExt => '.${this.langCode}';

  /// The generated file extension associated with the language, e.g. '.g.dart'.
  String get genExt => '.g.${this.langCode}';

  /// The template file extension associated with the language, e.g. '.dart.md'.
  String get tplExt => '.${this.langCode}.md';

  /// Whether [filePath] is a valid generated file path for the language.
  bool isValidGenFilePath(String filePath) {
    return filePath.toLowerCase().endsWith(this.genExt);
  }

  /// Whether [filePath] is a valid source file path for the language, i.e.
  /// a valid file path that is not a generated file path.
  bool isValidSrcFilePath(String filePath) {
    return this._isValidFilePath(filePath) &&
        !this.isValidGenFilePath(filePath);
  }

  /// Whether [filePath] is a valid file path for the language.
  bool _isValidFilePath(String filePath) {
    return filePath.toLowerCase().endsWith(this.srcExt);
  }

  /// Whether [filePath] is a valid template file path for the language.
  bool isValidTplFilePath(String filePath) {
    return filePath.toLowerCase().endsWith(this.tplExt);
  }

  /// Returns corresponding source file path for [filePath] or `null` if the
  /// [filePath] is invalid for this language.
  ///
  /// **Example for XyzGenLang.DART:**
  /// ```txt
  /// 'hello.dart' returns 'hello.dart'
  /// 'hello.g.dart' returns 'hello.dart'
  /// 'hello.world' returns null, since 'world' is not valid for XyzGenLang.DART.
  /// ```
  String? getCorrespondingSrcPathOrNull(String filePath) {
    final localSystemFilePath = toLocalSystemPathFormat(filePath);
    final dirName = p.dirname(localSystemFilePath);
    final baseName = p.basename(localSystemFilePath);
    final valid = this.isValidGenFilePath(localSystemFilePath);
    if (valid) {
      final baseNameNoExt =
          baseName.substring(0, baseName.length - this.genExt.length);
      final srcBaseName = '$baseNameNoExt${this.srcExt}';
      final result = p.join(dirName, srcBaseName);
      return result;
    }
    if (baseName.endsWith(this.srcExt)) {
      return localSystemFilePath;
    }
    return null;
  }

  /// Returns corresponding generated file path for [filePath] or `null` if
  /// [filePath] is invalid for this language.
  ///
  /// **Example for XyzGenLang.DART:**
  /// ```txt
  /// 'hello.g.dart' returns 'hello.g.dart'
  /// 'hello.dart' returns 'hello.g.dart'
  /// 'hello.g.world' returns null, since 'world' is not valid for XyzGenLang.DART.
  /// ```
  String? getCorrespondingGenPathOrNull(String filePath) {
    final localSystemFilePath = toLocalSystemPathFormat(filePath);
    final dirName = p.dirname(localSystemFilePath);
    final baseName = p.basename(localSystemFilePath);
    final valid = this.isValidSrcFilePath(localSystemFilePath);
    if (valid) {
      final baseNameNoExt =
          baseName.substring(0, baseName.length - this.srcExt.length);
      final srcBaseName = '$baseNameNoExt${this.srcExt}';
      final result = p.join(dirName, srcBaseName);
      return result;
    }
    if (baseName.endsWith(this.srcExt)) {
      return localSystemFilePath;
    }
    return null;
  }

  /// Whether the source-and-generated pair exists for the file at [filePath]
  /// or not.
  ///
  /// This means, if [filePath] exists and points to a source file, it also
  /// checks if its generated file exists at the same location. The reverse
  /// also holds true.
  Future<bool> srcAndGenPairExistsFor(String filePath) async {
    final a = await fileExists(filePath);
    if (!a) {
      return false;
    }
    if (this.isValidSrcFilePath(filePath)) {
      final b = await fileExists(
        '${filePath.substring(0, filePath.length - this.srcExt.length)}${this.genExt}',
      );
      return b;
    } else if (this.isValidGenFilePath(filePath)) {
      final b = await fileExists(
        '${filePath.substring(0, filePath.length - this.genExt.length)}${this.srcExt}',
      );
      return b;
    } else {
      return false;
    }
  }

  /// Deletes all source files from [dirPath] that match any of the provided
  /// [pathPatterns].
  ///
  /// If [pathPatterns] is not specified, all generated files will be deleted.
  /// The [onDelete] callback is called for each file after it is deleted.
  Future<void> deleteAllSrcFiles(
    String dirPath, {
    Set<String> pathPatterns = const {},
    Future<void> Function(String filePath)? onDelete,
  }) async {
    final filePaths = await listFilePaths(dirPath);
    if (filePaths != null) {
      final genFilePaths = filePaths.where(
        (e) =>
            this.isValidSrcFilePath(e) &&
            matchesAnyPathPattern(e, pathPatterns),
      );
      for (final filePath in genFilePaths) {
        await this.deleteSrcFile(filePath);
        await onDelete?.call(filePath);
      }
    }
  }

  /// Deletes the source file corresponding to [filePath] if it exists.
  ///
  /// Returns `true` if the file was successfully deleted, otherwise returns
  /// `false`.
  Future<bool> deleteSrcFile(String filePath) async {
    if (this.isValidSrcFilePath(filePath)) {
      try {
        await deleteFile(filePath);
        return true;
      } catch (_) {}
    }
    return false;
  }

  /// Deletes all generated files from [dirPath] that match any of the
  /// provided [pathPatterns].
  ///
  /// If [pathPatterns] is not specified, all generated files will be deleted.
  /// The [onDelete] callback is called for each file after it is deleted.
  Future<void> deleteAllGenFiles(
    String dirPath, {
    Set<String> pathPatterns = const {},
    Future<void> Function(String filePath)? onDelete,
  }) async {
    final filePaths = await listFilePaths(dirPath);
    if (filePaths != null) {
      final genFilePaths = filePaths.where(
        (e) =>
            this.isValidGenFilePath(e) &&
            matchesAnyPathPattern(e, pathPatterns),
      );
      for (final filePath in genFilePaths) {
        await this.deleteGenFile(filePath);
        await onDelete?.call(filePath);
      }
    }
  }

  /// Deletes the generated file corresponding to  [filePath] if it exists.
  ///
  /// Returns `true` if the file was successfully deleted, otherwise returns
  /// `false`.
  Future<bool> deleteGenFile(String filePath) async {
    if (this.isValidGenFilePath(filePath)) {
      try {
        await deleteFile(filePath);
        return true;
      } catch (_) {}
    }
    return false;
  }

  /// Converts [srcFileName] to a gen file name, e.g. 'hello.dart' -> '_hello.g.dart';
  String convertToGenFileName(String srcFileName) {
    final a = p
        .basename(srcFileName)
        .toLowerCase()
        .replaceLast(this.srcExt, this.genExt);
    final b = a.startsWith('_') ? a : '_$a';
    return b;
  }

  /// Converts [genFileName] to a src file name, e.g. '_hello.g.dart' -> 'hello.dart';
  String convertToSrcFileName(String genFileName) {
    final a = p
        .basename(genFileName)
        .toLowerCase()
        .replaceLast(this.genExt, this.srcExt);
    final b = a.startsWith('_') && a.length > 1 ? a.substring(1) : a;
    return b;
  }
}
