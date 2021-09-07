import 'package:reband_restful/reband_restful.dart';

import 'restful_fake_impls.dart';

part 'generat_example.reband.dart';

final myReband = FakeReband('https://api.m3o.com/v1');

@RESTfulApis(basePath: 'user/')
abstract class MyService with RebandService<FakeReband> {
  static MyService instance() => _$MyService(myReband);

  @GET('/{pn0}/{pn1}/profiles')
  Future<FakeReply> getByPathQuery(
    @Path('phn0') String ph0,
    @path String ph2,
    @Query('qn0') String q0,
    @queries Map<String, dynamic>? qs0,
    @query String q1,
  );

  @POST('commit')
  @HeaderMap({
    'xxx': 'yyy',
    'zzz': 'non',
  })
  Future<FakeReply> postByHeaderField(
    @Header('wow') String h0,
    @headers Map<String, String> hs0,
    @header int h1,
    @header bool xxx,
    @Field('fn0') f0,
    @fields Map<String, dynamic> fs0,
    @field f1,
  );

  @PUT('create')
  Future<FakeReply> putByMultipart(
    @Part(name: 'ptfn0') double pt0,
    @part int pt1,
    @Part(fileName: 'avatar.jpg', isFilePath: true) String imgPath,
    @Part(name: 'myProfile') Map<String, dynamic> profiles,
    @Part(fileName: 'moment.png') List<int> binary,
    @Part(isFilePath: true) String mySignature,
  );

  @PATCH('update')
  Future<FakeReply> patchByBody(
    @body dynamic b0,
    @body Stream<List<int>> stream,
  );
}
