// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generat_example.dart';

// **************************************************************************
// RebandServiceGenerator
// **************************************************************************

// ignore_for_file: equal_keys_in_map
class _$MyService extends MyService {
  _$MyService(this._reband$);

  final FakeReband _reband$;

  @override
  Future<FakeReply> getByPathQuery(
      String ph0, String ph2, String q0, Map<String, dynamic>? qs0, String q1) {
    final composedPath$ = <String, dynamic>{'phn0': ph0, 'ph2': ph2};
    final composedQuery$ = <String, dynamic>{
      'qn0': q0,
      ...?qs0,
      'q1': q1,
    };

    return _reband$.execute('GET', 'user/', '/{pn0}/{pn1}/profiles',
        pathMapper: composedPath$, queries: composedQuery$);
  }

  @override
  Future<FakeReply> postByHeaderField(
      Uri h0,
      dynamic h1,
      Map<String, String> hs0,
      String h2,
      dynamic f0,
      Map<String, dynamic>? fs0,
      dynamic f1) {
    final composedHeader$ = <String, String>{
      'X-Foo': 'Bar',
      'X-Ping': 'Pang',
      'Origin': h0.toString(),
      'Cookie': h1.toString(),
      ...hs0,
      'Accept': h2.toString(),
    };

    final composedField$ = <String, dynamic>{
      'fn0': f0,
      ...?fs0,
      'f1': f1,
    };

    return _reband$.execute('POST', 'user/', 'commit',
        headers: composedHeader$, fields: composedField$);
  }

  @override
  Future<FakeReply> putByMultipart(double pt0, int pt1, String imgPath,
      Map<String, dynamic> profiles, List<int> binary, String mySignature) {
    final composedPart$ = <Multipart>[
      Multipart('ptfn0', pt0),
      Multipart('pt1', pt1),
      Multipart('imgPath', imgPath, fileName: 'avatar.jpg', valueIsPath: true),
      Multipart('myProfile', profiles),
      Multipart('binary', binary, fileName: 'moment.png'),
      Multipart('mySignature', mySignature, valueIsPath: true)
    ];
    return _reband$.execute('PUT', 'user/', 'create',
        multiparts: composedPart$);
  }

  @override
  Future<FakeReply> patchByBody(dynamic b0, Stream<List<int>> stream) {
    final composedBody$ = <dynamic>[b0, stream];
    return _reband$.execute('PATCH', 'user/', 'update',
        annBodies: composedBody$);
  }
}
