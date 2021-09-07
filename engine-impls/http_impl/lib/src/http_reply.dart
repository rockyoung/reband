import 'package:http/http.dart';
import 'package:reband_restful/reband_restful.dart';

class HttpReply extends Reply<BaseResponse> {
  static int _onGetStatusCode(BaseResponse raw) => raw.statusCode;
  static Map<String, String> _onGetHeaders(BaseResponse raw) =>
      Map.unmodifiable(raw.headers);
  static dynamic _onGetBody(BaseResponse raw) {
    if (raw is Response) {
      return raw.body;
    }
    return null;
  }

  HttpReply(BaseResponse rawResponse)
      : super(rawResponse, _onGetStatusCode, _onGetHeaders, _onGetBody);
}
