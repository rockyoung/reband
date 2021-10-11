import 'package:http/http.dart';
import 'package:reband_restful/reband_restful.dart';

import 'http_apply.dart';
import 'http_reply.dart';

class HttpReband extends Reband<Client, HttpApply, HttpReply> {
  @override
  final Client engine;

  @override
  final String baseUrl;

  HttpReband(this.engine, {this.baseUrl = ''});

  @override
  HttpApply buildApply(String method, Uri uri,
          {Map<String, String>? headers, dynamic body}) =>
      HttpApply(method, uri, headers: headers, body: body);

  // @override
  // Future<HttpReply> launch(HttpApply apply) async =>
  //     HttpReply(await engine.send(await apply.submit()));

  @override
  Future<HttpReply> launch(HttpApply apply) async {
    final request = await apply.submit();
    final startMs = DateTime.now().millisecondsSinceEpoch;
    final response = await engine.send(request);
    final msConsumed = DateTime.now().millisecondsSinceEpoch - startMs;
    return HttpReply(response, msConsumed);
  }
}
