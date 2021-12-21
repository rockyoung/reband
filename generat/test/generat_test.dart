import 'dart:async';

// import 'package:path/path.dart' as p;
import 'package:reband_generat/src/reband_service_generator.dart';
import 'package:reband_restful/reband_restful.dart';

import 'package:source_gen_test/src/build_log_tracking.dart';
import 'package:source_gen_test/src/init_library_reader.dart';
import 'package:source_gen_test/src/test_annotated_classes.dart';

Future<void> main() async {
  final restfulApisTestReader = await initializeLibraryReaderForDirectory(
    // TODO separate `*_test_input` files into diff folder.
    'test',
    // TODO finish all remained test input cases.
    'restful_apis_test_input.dart',
  );

  initializeBuildLogTracking();
  testAnnotatedElements<RESTfulApis>(
    restfulApisTestReader,
    RebandServiceGenerator(),
  );
}
