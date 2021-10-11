import 'package:reband_restful/reband_restful.dart';

import 'restful_fake_impls.dart';

part 'generat_example.reband.dart';

final myReband = FakeReband('https://api.m3o.com/v1');

@RESTfulApis(basePath: '/my/end/point')
abstract class MyApiService {
  factory MyApiService.instance() => _$MyApiService(myReband);

  @GET('/{pn0}/{pn1}/profiles')
  Future<Reply> getByPathQuery(
    @Path('phn0') String ph0,
    @path String ph2,
    @Query('qn0') String q0,
    @queries Map<String, dynamic>? qs0,
    @query String q1,
  );

  @POST('commit')
  @HeaderMap({
    'X-Foo': 'Bar',
    'X-Ping': 'Pang',
  })
  Future<Reply> postByHeaderField(
    @Header('Origin') Uri h0,
    @Header('Cookie') dynamic h1,
    @headers Map<String, String> hs0,
    @Header('Accept') String h2,
    @Field('fn0') f0,
    @fields Map<String, dynamic>? fs0,
    @field f1,
  );

  @PUT('create')
  Future<Reply> putByMultipart(
    @Part(name: 'ptfn0') double pt0,
    @part int pt1,
    @Part(fileName: 'avatar.jpg', isFilePath: true) String imgPath,
    @Part(name: 'myProfile') Map<String, dynamic> profiles,
    @Part(fileName: 'moment.png') List<int> binary,
    @Part(isFilePath: true) String mySignature,
  );

  @PATCH('update')
  Future<Reply> patchByBody(
    @body dynamic b0,
    @body Stream<List<int>> stream,
  );
}

const rebandApis = RESTfulApis<FakeReband>(basePath: 'work');

@rebandApis
abstract class WorkApiService {
  static WorkApiService instance() => _$WorkApiService(myReband);

  @DELETE('/delete/path')
  Future<FakeReply> delete(@field String workId);
}

class MyRESTfulApis extends RESTfulApis<FakeReband> {
  const MyRESTfulApis({String basePath = ''}) : super(basePath: basePath);
}

@MyRESTfulApis(basePath: 'user')
abstract class UserApiService {
  factory UserApiService.create(FakeReband reband) = _$UserApiService;

  @HEAD('head/user')
  Future<FakeReply> head(@query String userId);
}

void main() {
  final myService = MyApiService.instance();
  // myService.getByPathQuery(ph0, ph2, q0, qs0, q1);
}
