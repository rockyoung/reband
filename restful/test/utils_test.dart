import 'package:reband_restful/src/utils.dart';
import 'package:test/test.dart';

void main() {
  group('utils.combineHttpUrl:', () {
    final baseUrl0 = 'https://api.test.com';
    final baseUrl1 = '$baseUrl0/';

    final path = 'example/http//path';

    final expectUrl = baseUrl1 + 'example/http/path';

    //   setUp(() {
    //     // Additional setup goes here.
    //   });

    test('baseUrl end with/without "/", path start with/without "/"', () {
      expect(combineHttpUrl(baseUrl0, path), equals(expectUrl));
      expect(combineHttpUrl(baseUrl0, '/$path'), equals(expectUrl));
      expect(combineHttpUrl(baseUrl0, '///$path'), equals(expectUrl));
      expect(combineHttpUrl(baseUrl1, path), equals(expectUrl));
      expect(combineHttpUrl(baseUrl1, '//$path'), equals(expectUrl));
    });

    test('baseUrl is ignored when path is a full-url already', () {
      expect(combineHttpUrl(baseUrl1, expectUrl), equals(expectUrl));
      expect(combineHttpUrl(path, expectUrl), equals(expectUrl));
    });

    test('both baseUrl and path are `path` actually', () {
      expect(combineHttpUrl('baseUrl', 'path'), equals('baseUrl/path'));
      expect(combineHttpUrl('baseUrl/', 'path'), equals('baseUrl/path'));
      expect(combineHttpUrl('baseUrl', '/path'), equals('baseUrl/path'));
      expect(combineHttpUrl('baseUrl/', '/path'), equals('baseUrl/path'));
    });
  });

  group('utils.buildHttpUriFrom:', () {
    test('only pathes replacement', () {
      final httpUrl = 'https://api.test.com/{a}/x{b}';
      final pathes = {
        'a': 1,
        'b': '2',
        'c': true,
      };
      expect(buildHttpUriFrom(httpUrl), equals(Uri.parse(httpUrl)));
      expect(buildHttpUriFrom(httpUrl, pathReplaces: pathes),
          equals(Uri.parse('https://api.test.com/1/x2')));
      expect(buildHttpUriFrom(httpUrl + '/{a}y', pathReplaces: pathes),
          equals(Uri.parse('https://api.test.com/1/x2/1y')));
      expect(buildHttpUriFrom(httpUrl + '/n?q={c}', pathReplaces: pathes),
          equals(Uri.parse('https://api.test.com/1/x2/n?q=true')));
    });

    test('only queries appending', () {
      final httpUrl = 'https://api.test.com/m';
      final querise = {
        'a': [1, '2'],
        'b': false,
      };
      expect(buildHttpUriFrom(httpUrl, appendQueries: querise),
          equals(Uri.parse('https://api.test.com/m?a=1&a=2&b=false')));
      expect(buildHttpUriFrom(httpUrl + '?c=bar', appendQueries: querise),
          equals(Uri.parse('https://api.test.com/m?c=bar&a=1&a=2&b=false')));
    });

    test('both pathes and queries', () {
      expect(
          buildHttpUriFrom('http://{a}.b.c/{d}/e?f=1', pathReplaces: {
            'a': 'aa',
            'd': 'dd',
          }, appendQueries: {
            'g': '2',
            'h': 3.4,
          }),
          equals(Uri.parse('http://aa.b.c/dd/e?f=1&g=2&h=3.4')));
    });

    test('bad httpUrl input', () {
      expect(buildHttpUriFrom('://1.2.3.4:::1'), equals(Uri()));
    });
  });
}
