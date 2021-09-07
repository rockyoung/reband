library reband_generat;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/reband_service_generator.dart';

Builder rebandBuilderFactory(BuilderOptions options) => PartBuilder(
      [RebandServiceGenerator()],
      '.reband.dart',
      header: options.config['header'],
    );
