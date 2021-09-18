import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

@internal
final rebandLogger = Logger('reband_restful');

/// Note: Do not use this function with `non-http` url and path!
///
/// Combine the [path] to the end of [baseUrl] with or without a slash symbol,
/// if the [path] is already start with a `http`/`https` scheme, the [baseUrl]
/// will be ignored.
///
/// [baseUrl] does not have to start with scheme, it can be just a path too,
/// it is your responsibility to make the *combined* `fullUrl` meaningful.
///
/// Missing slash will be added before combination, duplicate slashes may be
/// handled incorrectly if passed in params have `non-http` url part.
@internal
String combineHttpUrl(String baseUrl, String path) {
  final String fullUrl;
  if (path.startsWith('https://') || path.startsWith('http://')) {
    fullUrl = path;
  } else {
    // add missing slash before combination
    if (!baseUrl.endsWith('/') && !path.startsWith('/')) {
      baseUrl += '/';
    }
    fullUrl = baseUrl + path;
  }
  return fullUrl.replaceAll(RegExp(r'(?<!(http:|https:))/+'), '/');
}

/// Try to build out a HTTP/HTTPS [Uri] from [httpUrl] with the optional
/// [pathReplaces] and [appendQueries].
///
/// The processing for the `dynamic` type value of two maps will be slightly
/// different:
///  - for [pathReplaces], all same `{key}` presents will be replaced with
/// their corresponding values by convert them to `String` for [httpUrl], and
/// the replacement happens before uri parsing and queries appending;
///  - for [appendQueries], if value is `Iterable` type, it will be converted
/// to `Iterable<String>` by mapping each item with `toString()` call, while
/// all other types will be converted to `String` by `toString()` too, cause
/// both `String` and `Iterable<String>` are original supported by [Uri].
///
/// [appendQueries] **will NOT override** any query that already be in the
/// [httpUrl], even both has the same query `key`.
///
/// Empty uri will be returned if `Uri.tryParse(httpUrl)` feedback null.
@internal
Uri buildHttpUriFrom(
  String httpUrl, {
  final Map<String, dynamic>? pathReplaces,
  final Map<String, dynamic>? appendQueries,
}) {
  pathReplaces?.forEach((key, value) {
    httpUrl = httpUrl.replaceAll('{$key}', '$value');
  });

  final uri = Uri.tryParse(httpUrl);

  if (uri == null) {
    rebandLogger.warning('Empty uri will be returned instead of null!');
    return Uri();
  }

  if (!uri.scheme.startsWith('http')) {
    rebandLogger.warning('Builded uri is NOT a http uri!');
  }

  final mappedQueries = appendQueries?.map((key, value) {
    if (value is Iterable) {
      // to `Iterable<String>`
      value = value.map((it) => it.toString());
    } else {
      // to `String`.
      value = value.toString();
    }
    return MapEntry(key, value);
  });

  if (mappedQueries != null && mappedQueries.isNotEmpty) {
    String query;
    try {
      query = Uri(queryParameters: mappedQueries).query;
    } catch (e) {
      rebandLogger.severe(e);
      query = '';
    }

    if (query.isNotEmpty) {
      final origin = uri.query;
      if (origin.isNotEmpty) query = '$origin&$query';
      return uri.replace(query: query);
    }
  }

  return uri;
}
