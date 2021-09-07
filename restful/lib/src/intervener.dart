import 'dart:async';

import 'package:meta/meta.dart';

import 'apply.dart';
import 'reband_base.dart';
import 'reply.dart';

/// [Intervener] is also well knowed as `Interceptor`, they represent the same
/// thing.
///
/// **DO NOT** extends or implements from this directly, use [ApplyIntervener]
/// or [ReplyIntervener] instead.
///
/// _NOTE_: *exposed to out side just for type-checking.*
@internal
abstract class Intervener {}

/// Interveners to intervene [Apply]s through [beforeRequest], that means they
/// will be excuted only before [Reband.launch].
abstract class ApplyIntervener<T extends Apply> extends Intervener {
  FutureOr<T> beforeRequest(T apply);
}

/// Interveners to intervene [Reply]s through [afterResponse], which will be
/// called after [Reband.launch] immediately.
abstract class ReplyIntervener<T extends Reply> extends Intervener {
  FutureOr<T> afterResponse(T reply);
}

// abstract class Intervener<T> {
//   FutureOr<T> intercept(T applyOrReply);
// }
// abstract class ApplyIntervener<T extends Apply> extends Intervener<T> {
//   @override
//   FutureOr<T> intercept(T apply);
// }
// abstract class ReplyIntervener<T extends Reply> extends Intervener<T> {
//   @override
//   FutureOr<T> intercept(T reply);
// }

/// Below function typedef will disturb the public interface to user, and also
/// mess up the inner type checking logic.
// typedef BeforeRequest<T extends Apply> = FutureOr<T> Function(T);
// typedef AfterResponse<T extends Reply> = FutureOr<T> Function(T);

/// Interceptor of famous `okhttp` is good and the design is ingenious, but it
/// requires a bit of learning cost for users: the `intercept()` function is
/// called recursively through `Chain`, that means the top-most interceptor of
/// list will firstly invoke the code block before `chain.proceed()`, while
/// statements after `chain.proceed()` will be called lastly in sequence.
/// It also seems to force users to handle `beforeRequest` and `afterResponse`
/// at the same time, although it does not require that.
